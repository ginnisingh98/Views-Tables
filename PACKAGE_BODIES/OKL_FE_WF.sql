--------------------------------------------------------
--  DDL for Package Body OKL_FE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_WF" AS
/* $Header: OKLFEWFB.pls 120.2 2006/08/09 14:25:33 pagarg noship $ */
  -- constants used in the package

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

  --function to return the message from fnd message for the subject of the notifications

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

  -- get the message for a message name frm fnd messages

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

  -- get the message body for Pricing Adjustment Matrix

  FUNCTION get_pam_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'PAM_NAME');
    l_version_number := wf_engine.GetItemAttrText(itemtype,
                                                  itemkey,
                                                  'VERSION_NUMBER');
    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');
    lv_message_body := '<body>' ||
                       get_token('OKL_NAME', 'NAME', l_name) ||
                       '<br>' ||
                       get_token('OKL_VERSION',
                                 'VERSION',
                                 l_version_number) ||
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
    RETURN lv_message_body;
  END get_pam_msg_body;

  -- this method generates the message body

  PROCEDURE get_pam_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    -- get the message body

    document := get_pam_msg_body('OKLFEPAM', document_id);
    document_type := display_type;
  END get_pam_msg_doc;

  -- get the message body for Standard Rate Template

  FUNCTION get_srt_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'SRT_NAME');
    l_version_number := wf_engine.GetItemAttrText(itemtype,
                                                  itemkey,
                                                  'VERSION_NUMBER');
    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');
    lv_message_body := '<body>' ||
                       get_token('OKL_NAME', 'NAME', l_name) ||
                       '<br>' ||
                       get_token('OKL_VERSION',
                                 'VERSION',
                                 l_version_number) ||
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
    RETURN lv_message_body;
  END get_srt_msg_body;

  -- this method generates the message body

  PROCEDURE get_srt_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    -- get the message body

    document := get_srt_msg_body('OKLFESRT', document_id);
    document_type := display_type;
  END get_srt_msg_doc;

  -- get the message body for End of Term Options

  FUNCTION get_eot_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'EOT_NAME');
    l_version_number := wf_engine.GetItemAttrText(itemtype,
                                                  itemkey,
                                                  'VERSION_NUMBER');
    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');
    lv_message_body := '<body>' ||
                       get_token('OKL_NAME', 'NAME', l_name) ||
                       '<br>' ||
                       get_token('OKL_VERSION',
                                 'VERSION',
                                 l_version_number) ||
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
    RETURN lv_message_body;
  END get_eot_msg_body;

  -- this method generates the message body

  PROCEDURE get_eot_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    -- get the message body

    document := get_eot_msg_body('OKLFEEOT', document_id);
    document_type := display_type;
  END get_eot_msg_doc;

  -- get the message body for Item Residuals

  FUNCTION get_irs_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'IRS_NAME');
    l_version_number := wf_engine.GetItemAttrText(itemtype,
                                                  itemkey,
                                                  'VERSION_NUMBER');
    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');
    lv_message_body := '<body>' ||
                       get_token('OKL_NAME', 'NAME', l_name) ||
                       '<br>' ||
                       get_token('OKL_VERSION',
                                 'VERSION',
                                 l_version_number) ||
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
    RETURN lv_message_body;
  END get_irs_msg_body;

  -- this method generates the message body

  PROCEDURE get_irs_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    -- get the message body

    document := get_irs_msg_body('OKLFEIRS', document_id);
    document_type := display_type;
  END get_irs_msg_doc;

  -- get the message body for Lease Rate Sets

  FUNCTION get_lrs_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LRS_NAME');
    l_version_number := wf_engine.GetItemAttrText(itemtype,
                                                  itemkey,
                                                  'VERSION_NUMBER');
    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');
    lv_message_body := '<body>' ||
                       get_token('OKL_NAME', 'NAME', l_name) ||
                       '<br>' ||
                       get_token('OKL_VERSION',
                                 'VERSION',
                                 l_version_number) ||
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
    RETURN lv_message_body;
  END get_lrs_msg_body;

  -- this method generates the message body

  PROCEDURE get_lrs_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    -- get the message body

    document := get_lrs_msg_body('OKLFELRS', document_id);
    document_type := display_type;
  END get_lrs_msg_doc;

  -- method to set the messages and the message desciption

  PROCEDURE set_messages(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                         object_type IN VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'set_messages';
    l_name                      VARCHAR2(100);
    l_object_name               VARCHAR2(50);
    l_request_message           VARCHAR2(500);
    l_approved_message          VARCHAR2(500);
    l_rejected_message          VARCHAR2(500);
    l_reminder_message          VARCHAR2(500);
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(32767);
    x_return_status             VARCHAR2(1);
    l_api_version               NUMBER := 1.0;
    p_api_version               NUMBER := 1.0;

    CURSOR obj_name_csr(object_type IN VARCHAR2) IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_PRICING_OBJECTS' AND LOOKUP_CODE = object_type;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              'T',
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- RUN mode

    OPEN obj_name_csr(object_type);
    FETCH obj_name_csr INTO l_object_name ;
    CLOSE obj_name_csr;

    -- according to Object Type, the message is set

    IF (object_type = 'PAM') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'PAM_NAME');
      wf_engine.SetItemAttrDocument(itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      => G_WF_ITM_MESSAGE_BODY,
                                    documentid => 'plsql:okl_fe_wf.get_pam_msg_doc/' ||
                                    itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_pam_msg_body(itemtype,
                                                             itemkey));
    ELSIF (object_type = 'SRT') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'SRT_NAME');
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_BODY,
                                avalue   => 'plsql:okl_fe_wf.get_srt_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_srt_msg_body(itemtype,
                                                             itemkey));
    ELSIF (object_type = 'LRS') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LRS_NAME');
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_BODY,
                                avalue   => 'plsql:okl_fe_wf.get_lrs_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_lrs_msg_body(itemtype,
                                                             itemkey));
    ELSIF (object_type = 'EOT') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'EOT_NAME');
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_BODY,
                                avalue   => 'plsql:okl_fe_wf.get_eot_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_eot_msg_body(itemtype,
                                                             itemkey));
    ELSIF (object_type = 'IRS') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'IRS_NAME');
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_BODY,
                                avalue   => 'plsql:okl_fe_wf.get_irs_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_irs_msg_body(itemtype,
                                                             itemkey));
    END IF;

    -- set the messages of the notification

    l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                     l_object_name,
                                     l_name);
    l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                      l_object_name,
                                      l_name);
    l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                      l_object_name,
                                      l_name);
    l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                      l_object_name,
                                      l_name);
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
    EXCEPTION

      -- handle the exceptions

      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END set_messages;

  -- procedure to check the approval process

  PROCEDURE check_approval_process(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2, actid IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2) IS
    l_approval_option          VARCHAR2(10);
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'check_approval_process';

  BEGIN

    IF (funcmode = 'RUN') THEN

      -- get the profile option

      l_approval_option := fnd_profile.value('OKL_PE_APPROVAL_PROCESS');

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

  -- get the Standard Rate Template Data

  PROCEDURE get_std_rate_tmpl_data(itemtype IN varchar2, itemkey IN varchar2) IS
    l_srt_id         NUMBER;
    l_version_id     NUMBER;
    l_user_name      VARCHAR2(240);
    x_return_status  VARCHAR2(1);
    l_api_name       VARCHAR2(40) := 'get_std_rate_tmpl_data';
    x_msg_count      NUMBER;
    x_msg_data       VARCHAR2(32767);
    l_application_id fnd_application.application_id%TYPE;
    l_api_version    NUMBER := 1.0;
    p_api_version    NUMBER := 1.0;

    CURSOR get_srt_attributes(p_srt_version_id NUMBER) IS
      SELECT STD_RATE_TMPL_VER_ID,
             OBJECT_VERSION_NUMBER,
             VERSION_NUMBER,
             STD_RATE_TMPL_ID,
             EFFECTIVE_FROM_DATE,
             EFFECTIVE_TO_DATE,
             STS_CODE,
             ADJ_MAT_VERSION_ID,
             SRT_RATE,
             SPREAD,
             DAY_CONVENTION_CODE,
             MIN_ADJ_RATE,
             MAX_ADJ_RATE,
             CURRENCY_CODE,
             RATE_CARD_YN,
             PRICING_ENGINE_CODE,
             ORIG_STD_RATE_TMPL_ID,
             RATE_TYPE_CODE,
             FREQUENCY_CODE,
             INDEX_ID,
             HDR_STS_CODE,
             HDR_EFFECTIVE_FROM_DATE,
             HDR_EFFECTIVE_TO_DATE,
             HDR_SRT_RATE,
             TEMPLATE_NAME,
             TEMPLATE_DESC
        FROM OKL_FE_STD_RT_TMP_VERS_V
       WHERE STD_RATE_TMPL_VER_ID = p_srt_version_id;

    CURSOR fnd_user_csr IS
      SELECT USER_NAME
        FROM FND_USER
       WHERE USER_ID = fnd_global.user_id;

    -- Get the valid application id from FND

    CURSOR c_get_app_id_csr IS
      SELECT APPLICATION_ID
        FROM FND_APPLICATION
       WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              'T',
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the value of the version id from the workflow

    l_version_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

    -- set the values of the attributes from the values of the cursor

    FOR l_srt_rec IN get_srt_attributes(l_version_id)
      LOOP
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'SRT_NAME',
                                  l_srt_rec.TEMPLATE_NAME);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'DESCRIPTION',
                                  l_srt_rec.TEMPLATE_DESC);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'SRT_TYPE',
                                  l_srt_rec.RATE_TYPE_CODE);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'VERSION_NUMBER',
                                  l_srt_rec.VERSION_NUMBER);
        wf_engine.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'EFFECTIVE_FROM',
                                  l_srt_rec.EFFECTIVE_FROM_DATE);
        wf_engine.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'EFFECTIVE_TO',
                                  l_srt_rec.EFFECTIVE_TO_DATE);
      END LOOP;
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
                              l_version_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPLICATION_ID,
                              l_application_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END get_std_rate_tmpl_data;

  -- hdnle the approval of Standard Rate Template

  PROCEDURE handle_srt_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2) IS
    l_srt_id               NUMBER;
    l_api_version          NUMBER := 1.0;
    l_api_name             VARCHAR2(40) := 'handle_srt_approval';
    p_init_msg_list        VARCHAR2(1) := 'T';
    x_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lx_msg_count           NUMBER;
    l_result               VARCHAR2(30);
    lv_approval_status_ame VARCHAR2(30);
    lx_msg_data            VARCHAR2(32767);
    lx_return_status       VARCHAR2(1);
    l_srv_rec              okl_srv_rec;
    x_srv_rec              okl_srv_rec;

  BEGIN

    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');

      -- if approved, then change the status

      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN
        l_srt_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

        -- change the version and header status and end date referenced objects

        okl_fe_std_rate_tmpl_pvt.handle_approval(1,
                                                 'T',
                                                 lx_return_status,
                                                 lx_msg_count,
                                                 lx_msg_data,
                                                 l_srt_id);
        IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      ELSE
        l_srt_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

        -- populate the version attributes

        l_srv_rec.adj_mat_version_id := l_srt_id;
        l_srv_rec.sts_code := 'NEW';

        -- change the version status back to new

        okl_srv_pvt.update_row(l_api_version,
                               p_init_msg_list,
                               x_return_status,
                               lx_msg_count,
                               lx_msg_data,
                               l_srv_rec,
                               x_srv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      resultout := 'COMPLETE';
      RETURN;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT('okl_fe_wf',
                        'handle_srt_approval',
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END handle_srt_approval;

  -- get the adjustment matrix data

  PROCEDURE get_adj_matrix_get_data(itemtype IN varchar2, itemkey IN varchar2) IS
    l_adj_mat_version_id NUMBER;
    l_user_name          VARCHAR2(240);
    x_return_status      VARCHAR2(1);
    l_api_name           VARCHAR2(40) := 'get_adj_matrix_get_data';
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(32767);
    l_application_id     fnd_application.application_id%TYPE;
    l_api_version        NUMBER := 1.0;
    p_api_version        NUMBEr := 1.0;

    CURSOR get_adj_mat_attr(p_adj_mat_ver_id NUMBER) IS
      SELECT ADJ_MAT_VERSION_ID,
             OBJECT_VERSION_NUMBER,
             VERSION_NUMBER,
             ADJ_MAT_ID,
             STS_CODE,
             EFFECTIVE_FROM_DATE,
             EFFECTIVE_TO_DATE,
             CURRENCY_CODE,
             ADJ_MAT_TYPE_CODE,
             ORIG_ADJ_MAT_ID,
             HDR_STS_CODE,
             HDR_EFFECTIVE_FROM_DATE,
             HDR_EFFECTIVE_TO_DATE,
             ADJ_MAT_NAME,
             ADJ_MAT_DESC
        FROM OKL_FE_ADJ_MAT_VERS_V
       WHERE ADJ_MAT_VERSION_ID = p_adj_mat_ver_id;

    CURSOR fnd_user_csr IS
      SELECT USER_NAME
        FROM FND_USER
       WHERE USER_ID = fnd_global.user_id;

    -- Get the valid application id from FND

    CURSOR c_get_app_id_csr IS
      SELECT APPLICATION_ID
        FROM FND_APPLICATION
       WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              'T',
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the value of the version id from the workflow

    l_adj_mat_version_id := wf_engine.GetItemAttrText(itemtype,
                                                      itemkey,
                                                      'VERSION_ID');

    -- set the values of the attributes from the values of the cursor

    FOR l_adj_mat_rec IN get_adj_mat_attr(l_adj_mat_version_id)
      LOOP
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'PAM_NAME',
                                  l_adj_mat_rec.ADJ_MAT_NAME);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'CURRENCY',
                                  l_adj_mat_rec.CURRENCY_CODE);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'VERSION_NUMBER',
                                  l_adj_mat_rec.VERSION_NUMBER);
        wf_engine.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'EFFECTIVE_FROM',
                                  l_adj_mat_rec.EFFECTIVE_FROM_DATE);
        wf_engine.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'EFFECTIVE_TO',
                                  l_adj_mat_rec.EFFECTIVE_TO_DATE);
      END LOOP;
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
                              l_adj_mat_version_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPLICATION_ID,
                              l_application_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END get_adj_matrix_get_data;

  -- handle Pricing Adjustment Matrix Approval

  PROCEDURE handle_pam_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2) IS
    l_api_version          NUMBER := 1.0;
    l_api_name             VARCHAR2(40) := 'handle_pam_approval';
    p_init_msg_list        VARCHAR2(1) := 'T';
    x_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pam_id               NUMBER;
    lx_msg_count           NUMBER;
    l_result               VARCHAR2(30);
    lv_approval_status_ame VARCHAR2(30);
    lx_msg_data            VARCHAR2(32767);
    lx_return_status       VARCHAR2(1);
    l_pal_rec              okl_pal_rec;
    x_pal_rec              okl_pal_rec;

  BEGIN

    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');
      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN
        l_pam_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

        -- change the version and header status and end date referenced objects

        okl_fe_adj_matrix_pvt.handle_approval(1,
                                              'T',
                                              lx_return_status,
                                              lx_msg_count,
                                              lx_msg_data,
                                              l_pam_id);
        IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      ELSE
        l_pam_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

        -- populate the version attributes

        l_pal_rec.adj_mat_version_id := l_pam_id;
        l_pal_rec.sts_code := 'NEW';

        -- change the version status back to new

        okl_pal_pvt.update_row(l_api_version,
                               p_init_msg_list,
                               x_return_status,
                               lx_msg_count,
                               lx_msg_data,
                               l_pal_rec,
                               x_pal_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      resultout := 'COMPLETE';
      RETURN;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT('okl_fe_wf',
                        'handle_pam_approval',
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END handle_pam_approval;

  -- get end of Term Options Data

  PROCEDURE get_end_of_term_data(itemtype IN varchar2, itemkey IN varchar2) IS
    l_eot_version_id NUMBER;
    l_user_name      VARCHAR2(240);
    x_return_status  VARCHAR2(1);
    l_api_name       VARCHAR2(40) := 'get_end_of_term_data';
    x_msg_count      NUMBER;
    x_msg_data       VARCHAR2(32767);
    l_application_id fnd_application.application_id%TYPE;
    l_api_version    NUMBER := 1.0;
    p_api_version    NUMBER := 1.0;

    CURSOR get_end_of_term_attr(p_eot_version_id NUMBER) IS
      SELECT END_OF_TERM_VER_ID,
             OBJECT_VERSION_NUMBER,
             VERSION_NUMBER,
             END_OF_TERM_ID,
             STS_CODE,
             EFFECTIVE_FROM_DATE,
             EFFECTIVE_TO_DATE,
             CURRENCY_CODE,
             EOT_TYPE_CODE,
             PRODUCT_ID,
             CATEGORY_TYPE_CODE,
             ORIG_END_OF_TERM_ID,
             HDR_STS_CODE,
             HDR_EFFECTIVE_FROM_DATE,
             HDR_EFFECTIVE_TO_DATE,
             END_OF_TERM_NAME,
             END_OF_TERM_DESC
        FROM OKL_FE_EO_TERM_VERS_V
       WHERE END_OF_TERM_VER_ID = p_eot_version_id;

    -- find the user

    CURSOR fnd_user_csr IS
      SELECT USER_NAME
        FROM FND_USER
       WHERE USER_ID = fnd_global.user_id;

    -- Get the valid application id from FND

    CURSOR c_get_app_id_csr IS
      SELECT APPLICATION_ID
        FROM FND_APPLICATION
       WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              'T',
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the value of the version id from the workflow

    l_eot_version_id := wf_engine.GetItemAttrText(itemtype,
                                                  itemkey,
                                                  'VERSION_ID');

    -- set the values of the attributes from the values of the cursor

    FOR l_eot_val_rec IN get_end_of_term_attr(l_eot_version_id)
      LOOP
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'EOT_NAME',
                                  l_eot_val_rec.END_OF_TERM_NAME);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'DESCRIPTION',
                                  l_eot_val_rec.END_OF_TERM_DESC);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'SOURCE',
                                  l_eot_val_rec.CATEGORY_TYPE_CODE);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'VALUE_TYPE',
                                  l_eot_val_rec.CATEGORY_TYPE_CODE);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'CURRENCY',
                                  l_eot_val_rec.CURRENCY_CODE);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'VERSION_NUMBER',
                                  l_eot_val_rec.VERSION_NUMBER);
        wf_engine.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'EFFECTIVE_FROM',
                                  l_eot_val_rec.EFFECTIVE_FROM_DATE);
        wf_engine.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'EFFECTIVE_TO',
                                  l_eot_val_rec.EFFECTIVE_TO_DATE);
      END LOOP;
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
                              l_eot_version_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPLICATION_ID,
                              l_application_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END get_end_of_term_data;

  -- Handle end of term approval

  PROCEDURE handle_eot_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2) IS
    l_api_version          NUMBER := 1.0;
    l_api_name             VARCHAR2(40) := 'handle_eot_approval';
    p_init_msg_list        VARCHAR2(1) := 'T';
    x_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_eot_id               NUMBER;
    lx_msg_count           NUMBER;
    l_result               VARCHAR2(30);
    lv_approval_status_ame VARCHAR2(30);
    lx_msg_data            VARCHAR2(32767);
    lx_return_status       VARCHAR2(1);
    l_eve_rec              okl_eve_rec;
    x_eve_rec              okl_eve_rec;

  BEGIN

    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');
      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN
        l_eot_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

        -- change the version and header status and end date referenced objects

        okl_fe_eo_term_options_pvt.handle_approval(1,
                                                   'T',
                                                   lx_return_status,
                                                   lx_msg_count,
                                                   lx_msg_data,
                                                   l_eot_id);
        IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      ELSE
        l_eot_id := wf_engine.GetItemAttrText(itemtype,
                                              itemkey,
                                              'VERSION_ID');

        -- populate the version attributes

        l_eve_rec.end_of_term_ver_id := l_eot_id;
        l_eve_rec.sts_code := 'NEW';

        -- change the version status back to new

        okl_eve_pvt.update_row(l_api_version,
                               p_init_msg_list,
                               x_return_status,
                               lx_msg_count,
                               lx_msg_data,
                               l_eve_rec,
                               x_eve_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      resultout := 'COMPLETE';
      RETURN;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT('okl_fe_wf',
                        'handle_eot_approval',
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END handle_eot_approval;

  -- get the Lease Rate Set data

  PROCEDURE get_lrs_data(itemtype IN varchar2, itemkey IN varchar2) IS
    l_rate_set_ver_id NUMBER;
    l_user_name       VARCHAR2(240);
    x_return_status   VARCHAR2(1);
    l_api_name        VARCHAR2(40) := 'get_item_residual_data';
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(32767);
    l_application_id  fnd_application.application_id%TYPE;
    l_api_version     NUMBER := 1.0;
    p_api_version     NUMBER := 1.0;

    CURSOR get_lrs_attr(p_rate_set_ver_id NUMBER) IS
      SELECT A.ID,
             A.NAME,
             A.DESCRIPTION,
             A.LRS_TYPE_CODE,
             A.END_OF_TERM_ID,
             A.CURRENCY_CODE,
             A.FRQ_CODE,
             B.RATE_SET_VERSION_ID,
             B.STS_CODE,
             B.ARREARS_YN,
             B.EFFECTIVE_FROM_DATE,
             B.EFFECTIVE_TO_DATE,
             B.END_OF_TERM_VER_ID,
             B.STD_RATE_TMPL_VER_ID,
             B.ADJ_MAT_VERSION_ID,
             B.VERSION_NUMBER,
             B.LRS_RATE,
             B.RATE_TOLERANCE,
             B.RESIDUAL_TOLERANCE,
             B.DEFERRED_PMTS,
             B.ADVANCE_PMTS
        FROM OKL_LS_RT_FCTR_SETS_V A,
             OKL_FE_RATE_SET_VERSIONS B
       WHERE A.ID = B.RATE_SET_ID
         AND B.RATE_SET_VERSION_ID = p_rate_set_ver_id;
    l_lrv_rec get_lrs_attr%ROWTYPE;

    CURSOR fnd_user_csr IS
      SELECT USER_NAME
        FROM FND_USER
       WHERE USER_ID = fnd_global.user_id;

    -- Get the valid application id from FND

    CURSOR c_get_app_id_csr IS
      SELECT APPLICATION_ID
        FROM FND_APPLICATION
       WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              'T',
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the value of the version id from the workflow

    l_rate_set_ver_id := wf_engine.GetItemAttrText(itemtype,
                                                   itemkey,
                                                   'VERSION_ID');

    -- set the values of the attributes from the values of the cursor

    OPEN get_lrs_attr(l_rate_set_ver_id);
    FETCH get_lrs_attr INTO l_lrv_rec ;
    CLOSE get_lrs_attr;

    -- set all the attributes of Lease Rate Set

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'LRS_NAME',
                              l_lrv_rec.name);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'DESCRIPTION',
                              l_lrv_rec.description);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'TYPE',
                              l_lrv_rec.lrs_type_code);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'EOT_ID',
                              l_lrv_rec.end_of_term_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'CURRENCY',
                              l_lrv_rec.currency_code);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'FREQUENCY',
                              l_lrv_rec.frq_code);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_ID',
                              l_lrv_rec.rate_set_version_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_NUMBER',
                              l_lrv_rec.version_number);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_STATUS',
                              l_lrv_rec.STS_CODE);
    wf_engine.SetItemAttrDate(itemtype,
                              itemkey,
                              'EFFECTIVE_FROM',
                              l_lrv_rec.EFFECTIVE_FROM_DATE);
    wf_engine.SetItemAttrDate(itemtype,
                              itemkey,
                              'EFFECTIVE_TO',
                              l_lrv_rec.EFFECTIVE_TO_DATE);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'EOT_VERSION_ID',
                              l_lrv_rec.end_of_term_ver_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'SRT_VERSION_ID',
                              l_lrv_rec.STD_RATE_TMPL_VER_ID);
    wf_engine.SetItemAttrNumber(itemtype,
                                itemkey,
                                'RATE',
                                l_lrv_rec.lrs_Rate);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'ARREARS',
                              l_lrv_rec.arrears_yn);
    wf_engine.SetItemAttrNumber(itemtype,
                                itemkey,
                                'RATE_TOLERANCE',
                                l_lrv_rec.RATE_TOLERANCE);
    wf_engine.SetItemAttrNumber(itemtype,
                                itemkey,
                                'RESIDUAL_TOLERANCE',
                                l_lrv_rec.RESIDUAL_TOLERANCE);
    wf_engine.SetItemAttrNumber(itemtype,
                                itemkey,
                                'DEFERRED_PAYMENT',
                                l_lrv_rec.deferred_pmts);
    wf_engine.SetItemAttrNumber(itemtype,
                                itemkey,
                                'ADVANCE_PAYMENT',
                                l_lrv_rec.advance_pmts);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'ADJ_MAT_ID',
                              l_lrv_rec.ADJ_MAT_VERSION_ID);

    -- get the user name

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
                              l_rate_set_ver_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPLICATION_ID,
                              l_application_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END get_lrs_data;

  -- handle the Lease Rate Set approval

  PROCEDURE handle_lrs_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2) IS
    l_api_version          NUMBER := 1.0;
    l_api_name             VARCHAR2(40) := 'handle_lrs_approval';
    p_init_msg_list        VARCHAR2(1) := 'T';
    x_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rate_set_ver_id      NUMBER;
    lx_msg_count           NUMBER;
    lx_msg_data            VARCHAR2(32767);
    lx_return_status       VARCHAR2(1);
    l_return_status        VARCHAR2(1);
    l_result               VARCHAR2(30);
    lv_approval_status_ame VARCHAR2(30);
    l_lrvv_rec             okl_lrvv_rec;
    x_lrvv_rec             okl_lrvv_rec;

  BEGIN

    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');

      -- check if the workflow is approved or rejected

      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN

        -- change the status of the Lease Rate Set

        l_rate_set_ver_id := wf_engine.GetItemAttrText(itemtype,
                                                       itemkey,
                                                       'VERSION_ID');
        okl_lease_rate_Sets_pvt.activate_lease_rate_set(1,
                                                        'T',
                                                        lx_return_status,
                                                        lx_msg_count,
                                                        lx_msg_data,
                                                        l_rate_set_ver_id);
        IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      ELSE
        l_rate_set_ver_id := wf_engine.GetItemAttrText(itemtype,
                                                       itemkey,
                                                       'VERSION_ID');

        -- populate the version attributes

        l_lrvv_rec.rate_set_version_id := l_rate_set_ver_id;
        l_lrvv_rec.sts_code := 'NEW';

        -- change the version status back to new

        okl_lrv_pvt.update_row(l_api_version,
                               p_init_msg_list,
                               x_return_status,
                               lx_msg_count,
                               lx_msg_data,
                               l_lrvv_rec,
                               x_lrvv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      resultout := 'COMPLETE';
      RETURN;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT('okl_fe_wf',
                        'handle_lrs_approval',
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
        NULL;
  END handle_lrs_approval;

  -- Get the data of item Residual

  PROCEDURE get_item_residual_data(itemtype IN varchar2, itemkey IN varchar2) IS
    l_item_resdl_version_id NUMBER;
    l_src_code              VARCHAR2(30) := NULL;
    l_user_name             VARCHAR2(240);
    x_return_status         VARCHAR2(1);
    l_api_name              VARCHAR2(40) := 'get_item_residual_data';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(32767);
    l_application_id        fnd_application.application_id%TYPE;
    l_api_version           NUMBER := 1.0;
    p_api_version           NUMBER := 1.0;

    -- Cursor for Item

    CURSOR get_irs_attr_item(p_itm_resdl_ver_id NUMBER) IS
      SELECT IRHV.ITEM_RESIDUAL_ID,
             IRHV.CATEGORY_TYPE_CODE,
             IRHV.INVENTORY_ITEM_ID,
             IRHV.ORGANIZATION_ID,
             IRHV.CATEGORY_ID,
             IRHV.CATEGORY_SET_ID,
             IRHV.RESI_CATEGORY_SET_ID,
             IRHV.RESIDUAL_TYPE_CODE,
             IRHV.CURRENCY_CODE,
             INV.CONCATENATED_SEGMENTS NAME,
             ICPV.VERSION_NUMBER,
             ICPV.STS_CODE,
             ICPV.START_DATE,
             ICPV.END_DATE,
             ICPV.ID
        FROM OKL_FE_ITEM_RESIDUAL IRHV,
             OKL_ITM_CAT_RV_PRCS_V ICPV,
             MTL_SYSTEM_ITEMS_VL INV
       WHERE IRHV.INVENTORY_ITEM_ID = INV.INVENTORY_ITEM_ID
         AND IRHV.ORGANIZATION_ID = INV.ORGANIZATION_ID
         AND ICPV.ITEM_RESIDUAL_ID = IRHV.ITEM_RESIDUAL_ID
         AND ICPV.ID = p_itm_resdl_ver_id;

    -- Cursor for Item category

    CURSOR get_irs_attr_item_cat(p_itm_resdl_ver_id NUMBER) IS
      SELECT IRHV.ITEM_RESIDUAL_ID,
             IRHV.CATEGORY_TYPE_CODE,
             IRHV.INVENTORY_ITEM_ID,
             IRHV.ORGANIZATION_ID,
             IRHV.CATEGORY_ID,
             IRHV.CATEGORY_SET_ID,
             IRHV.RESI_CATEGORY_SET_ID,
             IRHV.RESIDUAL_TYPE_CODE,
             IRHV.CURRENCY_CODE,
             INVCAT.CATEGORY_CONCAT_SEGS NAME,
             ICPV.VERSION_NUMBER,
             ICPV.STS_CODE,
             ICPV.START_DATE,
             ICPV.END_DATE,
             ICPV.ID
        FROM OKL_FE_ITEM_RESIDUAL IRHV,
             OKL_ITM_CAT_RV_PRCS_V ICPV,
             MTL_CATEGORIES_V INVCAT
       WHERE IRHV.CATEGORY_ID = INVCAT.CATEGORY_ID
         AND ICPV.ITEM_RESIDUAL_ID = IRHV.ITEM_RESIDUAL_ID
         AND ICPV.ID = p_itm_resdl_ver_id;

    -- Cursor for Residual category set

    CURSOR get_irs_attr_res_cat(p_itm_resdl_ver_id NUMBER) IS
      SELECT IRHV.ITEM_RESIDUAL_ID,
             IRHV.CATEGORY_TYPE_CODE,
             IRHV.INVENTORY_ITEM_ID,
             IRHV.ORGANIZATION_ID,
             IRHV.CATEGORY_ID,
             IRHV.CATEGORY_SET_ID,
             IRHV.RESI_CATEGORY_SET_ID,
             IRHV.RESIDUAL_TYPE_CODE,
             IRHV.CURRENCY_CODE,
             RCSV.RESI_CAT_NAME NAME,
             ICPV.VERSION_NUMBER,
             ICPV.STS_CODE,
             ICPV.START_DATE,
             ICPV.END_DATE,
             ICPV.ID
        FROM OKL_FE_ITEM_RESIDUAL IRHV,
             OKL_ITM_CAT_RV_PRCS_V ICPV,
             OKL_FE_RESI_CAT_V RCSV
       WHERE IRHV.RESI_CATEGORY_SET_ID = RCSV.RESI_CATEGORY_SET_ID
         AND ICPV.ITEM_RESIDUAL_ID = IRHV.ITEM_RESIDUAL_ID
         AND ICPV.ID = p_itm_resdl_ver_id;
    l_attr_rec get_irs_attr_item%ROWTYPE;

    CURSOR fnd_user_csr IS
      SELECT USER_NAME
        FROM FND_USER
       WHERE USER_ID = fnd_global.user_id;

    -- Get the valid application id from FND

    CURSOR c_get_app_id_csr IS
      SELECT APPLICATION_ID
        FROM FND_APPLICATION
       WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

    CURSOR c_get_cat_type(p_item_resdl_version_id NUMBER) IS
      SELECT IRHV.CATEGORY_TYPE_CODE
        FROM OKL_FE_ITEM_RESIDUAL IRHV,
             OKL_ITM_CAT_RV_PRCS_V ICPV
       WHERE IRHV.ITEM_RESIDUAL_ID = ICPV.ITEM_RESIDUAL_ID
         AND ICPV.ID = p_item_resdl_version_id;    -- Item residual version ID

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              'T',
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the value of the version id from the workflow

    l_item_resdl_version_id := wf_engine.GetItemAttrText(itemtype,
                                                         itemkey,
                                                         'VERSION_ID');/*
      Select the category type of the item residual.
     */
    OPEN c_get_cat_type(l_item_resdl_version_id);
    FETCH c_get_cat_type INTO l_src_code ;-- variable that indicates whether it is an Item or item category or a residual category set
    CLOSE c_get_cat_type;
    CASE l_src_code
      WHEN G_CAT_ITEM THEN
        OPEN get_irs_attr_item(l_item_resdl_version_id);
        FETCH get_irs_attr_item INTO l_attr_rec ;
        CLOSE get_irs_attr_item;
      WHEN G_CAT_ITEM_CAT THEN
        OPEN get_irs_attr_item_cat(l_item_resdl_version_id);
        FETCH get_irs_attr_item_cat INTO l_attr_rec ;
        CLOSE get_irs_attr_item_cat;
      WHEN G_CAT_RES_CAT THEN
        OPEN get_irs_attr_res_cat(l_item_resdl_version_id);
        FETCH get_irs_attr_res_cat INTO l_attr_rec ;
        CLOSE get_irs_attr_res_cat;
    END CASE;

    -- set the attributes of the workflow

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'IRS_NAME',
                              l_attr_rec.name);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'SOURCE',
                              l_attr_rec.category_type_code);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'INVENTORY_ITEM_ID',
                              l_attr_rec.inventory_item_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'ORGANIZATION_ID',
                              l_attr_rec.organization_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'CATEGORY_ID',
                              l_attr_rec.category_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'CATEGORY_SET_ID',
                              l_attr_rec.category_set_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'RCS_ID',
                              l_attr_rec.resi_category_set_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'RESIDUAL_TYPE',
                              l_attr_rec.residual_type_code);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'CURRENCY',
                              l_attr_rec.currency_code);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'IRS_NAME',
                              l_attr_rec.name);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_NUMBER',
                              l_attr_rec.version_number);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_STATUS',
                              l_attr_rec.sts_code);
    wf_engine.SetItemAttrDate(itemtype,
                              itemkey,
                              'EFFECTIVE_FROM',
                              l_attr_rec.start_date);
    wf_engine.SetItemAttrDate(itemtype,
                              itemkey,
                              'EFFECTIVE_TO',
                              l_attr_rec.end_date);
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
                              l_item_resdl_version_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPLICATION_ID,
                              l_application_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END get_item_residual_data;

  -- Handle Item Residual Approval process

  PROCEDURE handle_irs_approval(itemtype IN varchar2, itemkey IN varchar2,
                                actid IN number, funcmode IN varchar2,
                                resultout OUT NOCOPY varchar2) IS
    l_api_version           NUMBER := 1.0;
    l_api_name              VARCHAR2(40) := 'handle_irs_approval';
    p_init_msg_list         VARCHAR2(1) := 'T';
    x_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_item_resdl_version_id NUMBER;
    lx_msg_count            NUMBER;
    l_return_status         VARCHAR2(1);
    l_result                VARCHAR2(30);
    lv_approval_status_ame  VARCHAR2(30);
    lx_msg_data             VARCHAR2(32767);
    lx_return_status        VARCHAR2(1);
    l_icpv_rec              okl_icpv_rec;
    x_icpv_rec              okl_icpv_rec;

  BEGIN

    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');
      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN
        l_item_resdl_version_id := wf_engine.GetItemAttrText(itemtype,
                                                             itemkey,
                                                             'VERSION_ID');

        -- change the version and header status and end date referenced objects

        OKL_ITEM_RESIDUALS_PVT.activate_item_residual(1,
                                                      'T',
                                                      l_return_status,
                                                      lx_msg_count,
                                                      lx_msg_data,
                                                      l_item_resdl_version_id);
        IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      ELSE
        l_item_resdl_version_id := wf_engine.GetItemAttrText(itemtype,
                                                             itemkey,
                                                             'VERSION_ID');

        -- populate the version attributes

        l_icpv_rec.id := l_item_resdl_version_id;
        l_icpv_rec.sts_code := 'NEW';

        -- change the version status back to new

        okl_icp_pvt.update_row(l_api_version,
                               p_init_msg_list,
                               x_return_status,
                               lx_msg_count,
                               lx_msg_data,
                               l_icpv_rec,
                               x_icpv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      resultout := 'COMPLETE';
      RETURN;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT('okl_fe_wf',
                        'handle_irs_approval',
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END handle_irs_approval;

  -- method to set the messages and the message desciption

  PROCEDURE adj_mat_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS
    l_api_name            CONSTANT VARCHAR2(30) DEFAULT 'process_pool_ame';
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.PROCESS_POOL_AME';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    l_name                         VARCHAR2(100);
    l_object_name                  VARCHAR2(50);
    l_request_message              VARCHAR2(500);
    l_approved_message             VARCHAR2(500);
    l_rejected_message             VARCHAR2(500);
    l_reminder_message             VARCHAR2(500);

    CURSOR obj_name_csr IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_PRICING_OBJECTS' AND LOOKUP_CODE = 'PAM';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN
      get_adj_matrix_get_data(itemtype, itemkey);
      OPEN obj_name_csr;
      FETCH obj_name_csr INTO l_object_name ;
      CLOSE obj_name_csr;

      -- get the messages and set the messages accordingly depending on the object type

      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'PAM_NAME');
      l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                       l_object_name,
                                       l_name);
      l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                        l_object_name,
                                        l_name);
      l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                        l_object_name,
                                        l_name);
      l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                        l_object_name,
                                        l_name);
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
                                avalue   => 'plsql:okl_fe_wf.get_pam_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_pam_msg_body(itemtype,
                                                             itemkey));
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
  END adj_mat_ame;

  -- method to set the messages and the message desciption

  PROCEDURE adj_mat_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                       actid IN NUMBER, funcmode IN VARCHAR2,
                       resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'adj_mat_wf';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      -- set all the attributes required

      get_adj_matrix_get_data(itemtype, itemkey);

      -- set all the messages for the notification

      set_messages(itemtype, itemkey, 'PAM');
      resultout := 'COMPLETE';
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
  END adj_mat_wf;

  -- method to set the messages and the message desciption

  PROCEDURE std_rate_tmpl_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                              actid IN NUMBER, funcmode IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'std_rate_tmpl_ame';
    l_name                      VARCHAR2(100);
    l_object_name               VARCHAR2(50);
    l_request_message           VARCHAR2(500);
    l_approved_message          VARCHAR2(500);
    l_rejected_message          VARCHAR2(500);
    l_reminder_message          VARCHAR2(500);

    CURSOR obj_name_csr IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_PRICING_OBJECTS' AND LOOKUP_CODE = 'SRT';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      get_std_rate_tmpl_data(itemtype, itemkey);

      OPEN obj_name_csr;
      FETCH obj_name_csr INTO l_object_name ;
      CLOSE obj_name_csr;
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'SRT_NAME');
      l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                       l_object_name,
                                       l_name);
      l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                        l_object_name,
                                        l_name);
      l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                        l_object_name,
                                        l_name);
      l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                        l_object_name,
                                        l_name);
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
                                avalue   => 'plsql:okl_fe_wf.get_srt_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_srt_msg_body(itemtype,
                                                             itemkey));
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
  END std_rate_tmpl_ame;

  -- method to set the messages and the message desciption

  PROCEDURE std_rate_tmpl_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                             actid IN NUMBER, funcmode IN VARCHAR2,
                             resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'std_rate_tmpl_wf';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      -- set all the attributes required

      get_std_rate_tmpl_data(itemtype, itemkey);

      -- set all the messages for the notification

      set_messages(itemtype, itemkey, 'SRT');
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
  END std_rate_tmpl_wf;

  -- method to set the message body and message description

  PROCEDURE eo_term_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'eo_term_ame';
    l_name                      VARCHAR2(100);
    l_object_name               VARCHAR2(50);
    l_request_message           VARCHAR2(500);
    l_approved_message          VARCHAR2(500);
    l_rejected_message          VARCHAR2(500);
    l_reminder_message          VARCHAR2(500);

    CURSOR obj_name_csr IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_PRICING_OBJECTS' AND LOOKUP_CODE = 'EOT';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN
      -- set all the attributes required
      get_end_of_term_data(itemtype, itemkey);

      OPEN obj_name_csr;
      FETCH obj_name_csr INTO l_object_name ;
      CLOSE obj_name_csr;
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'EOT_NAME');
      l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                       l_object_name,
                                       l_name);
      l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                        l_object_name,
                                        l_name);
      l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                        l_object_name,
                                        l_name);
      l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                        l_object_name,
                                        l_name);
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
                                avalue   => 'plsql:okl_fe_wf.get_eot_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_eot_msg_body(itemtype,
                                                             itemkey));
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
  END eo_term_ame;

  -- method to set the messages and the message desciption

  PROCEDURE eo_term_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                       actid IN NUMBER, funcmode IN VARCHAR2,
                       resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'eo_term_wf';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      -- set all the attributes required

      get_end_of_term_data(itemtype, itemkey);

      -- set all the messages for the notification

      set_messages(itemtype, itemkey, 'EOT');
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
  END eo_term_wf;

  -- method to set the message and message description

  PROCEDURE item_res_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                         actid IN NUMBER, funcmode IN VARCHAR2,
                         resultout OUT NOCOPY VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'item_res_ame';
    l_name                      VARCHAR2(100);
    l_object_name               VARCHAR2(50);
    l_request_message           VARCHAR2(500);
    l_approved_message          VARCHAR2(500);
    l_rejected_message          VARCHAR2(500);
    l_reminder_message          VARCHAR2(500);

    CURSOR obj_name_csr IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_PRICING_OBJECTS' AND LOOKUP_CODE = 'IRS';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN
      -- set all the attributes required
     get_item_residual_data(itemtype, itemkey);

      OPEN obj_name_csr;
      FETCH obj_name_csr INTO l_object_name ;
      CLOSE obj_name_csr;
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'IRS_NAME');
      l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                       l_object_name,
                                       l_name);
      l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                        l_object_name,
                                        l_name);
      l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                        l_object_name,
                                        l_name);
      l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                        l_object_name,
                                        l_name);
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
                                avalue   => 'plsql:okl_fe_wf.get_irs_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_irs_msg_body(itemtype,
                                                             itemkey));
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
  END item_res_ame;

  -- method to set the messages and the message desciption

  PROCEDURE item_res_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'item_res_wf';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      -- set all the attributes required

      get_item_residual_data(itemtype, itemkey);

      -- set all the messages for the notification

      set_messages(itemtype, itemkey, 'IRS');
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
  END item_res_wf;

  -- method to set the Lease Rate Set messages and message description

  PROCEDURE lease_rate_set_ame(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                               actid IN NUMBER, funcmode IN VARCHAR2,
                               resultout OUT NOCOPY VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'lease_rate_set_ame';
    l_name                      VARCHAR2(100);
    l_object_name               VARCHAR2(50);
    l_request_message           VARCHAR2(500);
    l_approved_message          VARCHAR2(500);
    l_rejected_message          VARCHAR2(500);
    l_reminder_message          VARCHAR2(500);

    CURSOR obj_name_csr IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_PRICING_OBJECTS' AND LOOKUP_CODE = 'LRS';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN
      -- set all the attributes required
      get_lrs_data(itemtype, itemkey);

      OPEN obj_name_csr;
      FETCH obj_name_csr INTO l_object_name ;
      CLOSE obj_name_csr;
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LRS_NAME');
      l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                       l_object_name,
                                       l_name);
      l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                        l_object_name,
                                        l_name);
      l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                        l_object_name,
                                        l_name);
      l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                        l_object_name,
                                        l_name);
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
                                avalue   => 'plsql:okl_fe_wf.get_lrs_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_lrs_msg_body(itemtype,
                                                             itemkey));
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
  END lease_rate_set_ame;

  -- method to set the messages and the message desciption

  PROCEDURE lease_rate_set_wf(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                              actid IN NUMBER, funcmode IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'lease_rate_set_wf';

  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      -- set all the attributes required

      get_lrs_data(itemtype, itemkey);

      -- set all the messages for the notification

      set_messages(itemtype, itemkey, 'LRS');
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
  END lease_rate_set_wf;

END okl_fe_wf;

/
