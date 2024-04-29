--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_APP_WF" AS
/* $Header: OKLLAWFB.pls 120.2 2005/11/28 15:53:59 viselvar noship $ */

  ---------------------------------------------------
  -- Global Constants
  ---------------------------------------------------
  G_FE_APPROVAL_WF             CONSTANT VARCHAR2(2) := 'WF';
  G_FE_APPROVAL_AME            CONSTANT VARCHAR2(3) := 'AME';

  G_WF_ITM_APPLICATION_ID      CONSTANT VARCHAR2(20) := 'APPLICATION_ID';
  G_WF_ITM_TRANSACTION_ID      CONSTANT VARCHAR2(20) := 'TRANSACTION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID CONSTANT VARCHAR2(20) := 'TRX_TYPE_ID';
  G_WF_ITM_APPROVER            CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVER';
  G_WF_ITM_REQUESTER           CONSTANT VARCHAR2(20) := 'REQUESTER';
  G_WF_ITM_REQUESTER_ID        CONSTANT VARCHAR2(20) := 'REQUESTOR_ID';

  G_WF_ITM_APP_REQUEST_SUB     CONSTANT VARCHAR2(30) := 'APP_REQUEST_SUB';
  G_WF_ITM_APP_REMINDER_SUB    CONSTANT VARCHAR2(30) := 'APP_REMINDER_SUB';
  G_WF_ITM_APP_APPROVED_SUB    CONSTANT VARCHAR2(30) := 'APP_APPROVED_SUB';
  G_WF_ITM_APP_REJECTED_SUB    CONSTANT VARCHAR2(30) := 'APP_REJECTED_SUB';
  G_WF_ITM_APP_REMINDER_HEAD   CONSTANT VARCHAR2(30) := 'APP_REMINDER_HEAD';
  G_WF_ITM_APP_APPROVED_HEAD   CONSTANT VARCHAR2(30) := 'APP_APPROVED_HEAD';
  G_WF_ITM_APP_REJECTED_HEAD   CONSTANT VARCHAR2(30) := 'APP_REJECTED_HEAD';

  G_WF_ITM_MESSAGE_SUBJECT     CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_SUBJECT';
  G_WF_ITM_MESSAGE_DESCR       CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DESCRIPTION';
  G_WF_ITM_MESSAGE_BODY        CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DOC';

  G_WF_ITM_APPROVED_YN_YES     CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVED';
  ---------------------------------------------------
  -- Global Cursor definition
  ---------------------------------------------------
  -- Get the requester name
  CURSOR fnd_user_csr IS
    SELECT USER_NAME
      FROM FND_USER
     WHERE USER_ID = fnd_global.user_id;

  -- Get the valid application id from FND
  CURSOR c_get_app_id_csr IS
    SELECT APPLICATION_ID
      FROM FND_APPLICATION
     WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

    CURSOR obj_name_csr(object_type IN VARCHAR2) IS
      SELECT MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'OKL_FRONTEND_OBJECTS'
         AND LOOKUP_CODE = object_type;

  --function to return the message from fnd message for the subject of the notifications

  FUNCTION get_message(p_msg_name IN VARCHAR2, object_name IN VARCHAR2,
                       object_value IN VARCHAR2) RETURN VARCHAR2 IS
    l_message VARCHAR2(100);

  BEGIN

    IF p_msg_name IS NOT NULL THEN
      Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME, NAME        => p_msg_name);
      Fnd_Message.SET_TOKEN(TOKEN => 'OBJECT_NAME',
                            VALUE => object_name);
      Fnd_Message.SET_TOKEN(TOKEN => 'NAME', VALUE => object_value);
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
      Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME, NAME => p_msg_name);
      Fnd_Message.SET_TOKEN(TOKEN => token_name, VALUE => token_value);
      l_message := fnd_message.get();
    END IF;
    RETURN l_message;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
  END get_token;

  -- get the message body for Lease Application Template
  FUNCTION get_lat_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LAT_NAME');
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
  END get_lat_msg_body;

  -- get the message body for Lease Application
  FUNCTION get_lease_app_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    l_name           VARCHAR2(240);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);

  BEGIN
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LA_NAME');

    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');
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
    RETURN lv_message_body;
  END get_lease_app_msg_body;

  PROCEDURE get_lease_app_details (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'get_lease_app_details';
    x_return_status             VARCHAR2(1);
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(32767);

    l_lease_app_id OKL_LEASE_APPLICATIONS_V.ID%TYPE;
    l_user_name             VARCHAR2(240);
    l_application_id        fnd_application.application_id%TYPE;

   CURSOR c_get_lease_app_details (cp_la_id OKL_LEASE_APPLICATIONS_V.ID%TYPE) IS
    SELECT LAP.REFERENCE_NUMBER   LEASE_APP_NAME
         , LAP.APPLICATION_STATUS LEASE_APP_STATUS
         , LAP.VALID_FROM         EFFECTIVE_FROM
         , LAP.VALID_TO           EFFECTIVE_TO
      FROM OKL_LEASE_APPLICATIONS_V LAP
     WHERE LAP.ID = cp_la_id;

  l_lease_app_rec c_get_lease_app_details%ROWTYPE;
  BEGIN
      -- get the value of the version id from the workflow
      l_lease_app_id := wf_engine.GetItemAttrText(itemtype,
                                                    itemkey,
                                                    'LA_ID');

      -- set the attributes required in the workflow
      OPEN c_get_lease_app_details(l_lease_app_id);
        FETCH c_get_lease_app_details INTO l_lease_app_rec;
      CLOSE c_get_lease_app_details;

      -- set the attributes of the workflow
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                'LA_NAME',
                                l_lease_app_rec.lease_app_name);

      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                'EFFECTIVE_FROM',
                                l_lease_app_rec.effective_from);

      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                'EFFECTIVE_TO',
                                l_lease_app_rec.effective_to);

    -- Set the attributes on the Approver, requestor
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
                              l_lease_app_id);
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
                                                     '_WF');
        RAISE;
  END get_lease_app_details;

  -- Start of comments
  --
  -- Procedure Name  : get_la_approval_msg_doc
  -- Description     : Sets the message document for notification for Lease
  --                   Application approval
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE get_la_approval_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- get the message body
    document := get_lease_app_msg_body('OKLSOLAP', document_id);
    document_type := display_type;
  END get_la_approval_msg_doc;

  -- Sets the subjects of messages which are sent from the workflow notifications
  PROCEDURE set_messages(itemtype    IN VARCHAR2
                           , itemkey     IN VARCHAR2
                           , object_type IN VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'set_messages';
    l_name                      VARCHAR2(100);
    l_object_name               VARCHAR2(50);
    l_request_message           VARCHAR2(500);
    l_approved_message          VARCHAR2(500);
    l_rejected_message          VARCHAR2(500);
    l_reminder_message          VARCHAR2(500);
    x_return_status             VARCHAR2(1);

    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(32767);

  BEGIN
    OPEN obj_name_csr(object_type);
      FETCH obj_name_csr INTO l_object_name;
    CLOSE obj_name_csr;

    IF (itemtype = 'OKLSTLAT') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LAT_NAME');

      wf_engine.SetItemAttrDocument(itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      => G_WF_ITM_MESSAGE_BODY,
                                    documentid => 'plsql:okl_lease_app_wf.get_lat_msg_doc/' ||
                                    itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_lat_msg_body(itemtype,
                                                             itemkey));
    ELSIF (itemtype = 'OKLSOLAW') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LA_NAME');

      wf_engine.SetItemAttrDocument(itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      => G_WF_ITM_MESSAGE_BODY,
                                    documentid => 'plsql:okl_lease_app_wf.get_la_withdraw_msg_doc/' ||
                                    itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_lease_app_msg_body(itemtype,
                                                             itemkey));
    ELSIF (itemtype = 'OKLSOLAP') THEN
      l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LA_NAME');

      wf_engine.SetItemAttrDocument(itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      => G_WF_ITM_MESSAGE_BODY,
                                    documentid => 'plsql:okl_lease_app_wf.get_la_approval_msg_doc/' ||
                                    itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_lease_app_msg_body(itemtype,
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
    WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                    G_PKG_NAME,
                                                    'OTHERS',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_WF');
      RAISE;
  END set_messages;

  -- Start of comments
  --
  -- Procedure Name  : get_lat_msg_doc
  -- Description     : Sets the message document for notification for Lease
  --                   Application template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE get_lat_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- get the message body
    document := get_lat_msg_body('OKLSTLAT', document_id);
    document_type := display_type;
  END get_lat_msg_doc;

  -- Start of comments
  --
  -- Procedure Name  : get_la_withdraw_msg_doc
  -- Description     : Sets the message document for notification for Lease
  --                   Application withdrawal
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE get_la_withdraw_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- get the message body
    document := get_lease_app_msg_body('OKLSOLAW', document_id);
    document_type := display_type;
  END get_la_withdraw_msg_doc;


  -- Query the Lease Application Template details and set in Workflow attributes
  -- for displaying notifications
  PROCEDURE get_lat_ver_data(itemtype IN VARCHAR2,
                             itemkey IN VARCHAR2) IS
    l_api_name         CONSTANT VARCHAR2(30) DEFAULT 'set_messages';
    x_return_status             VARCHAR2(1);
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(32767);

    l_user_name             VARCHAR2(240);
    l_application_id        fnd_application.application_id%TYPE;
    l_lat_version_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE;

    CURSOR c_get_lat_details(cp_lat_ver_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE) IS
      SELECT LATV.NAME           LAT_NAME
           , LAVV.VERSION_NUMBER
           , LAVV.VALID_FROM     EFFECTIVE_FROM
           , LAVV.VALID_TO       EFFECTIVE_TO
           , LAVV.VERSION_STATUS
        FROM OKL_LEASEAPP_TEMPLATES     LATV
           , OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV
       WHERE LAVV.LEASEAPP_TEMPLATE_ID = LATV.ID
         AND LAVV.ID = cp_lat_ver_id;

   lp_lat_dtls_rec c_get_lat_details%ROWTYPE;

  BEGIN

    -- get the value of the version id from the workflow
    l_lat_version_id := wf_engine.GetItemAttrText(itemtype,
                                                         itemkey,
                                                         'VERSION_ID');

    -- Query the details of the Lease Application Template
    OPEN c_get_lat_details(l_lat_version_id);
      FETCH c_get_lat_details INTO lp_lat_dtls_rec;
    CLOSE c_get_lat_details;

    -- set the attributes of the workflow
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'LAT_NAME',
                              lp_lat_dtls_rec.lat_name);

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_NUMBER',
                              lp_lat_dtls_rec.version_number);

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'VERSION_STATUS',
                              lp_lat_dtls_rec.version_number);

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'EFFECTIVE_FROM',
                              lp_lat_dtls_rec.effective_from);

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'EFFECTIVE_TO',
                              lp_lat_dtls_rec.effective_to);

    -- Set the attributes on the Approver, requestor
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
                              l_lat_version_id);
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
                                                     '_WF');
        RAISE;
  END get_lat_ver_data;

-- Start of comments
--
-- Procedure Name  : check_approval_process
-- Description     : Procedure to check if the Approval Process is Workflow driven
--                   or through AME.
-- Business Rules  : Checks the Frontend profile and directs the approval flow
--                   accordingly
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE check_approval_process(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2,
                                   actid IN NUMBER,
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

    -- CANCEL or TIMEOUT mode
    IF (funcmode = 'CANCEL' OR funcmode = 'TIMEOUT') THEN
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

-- Start of comments
--
-- Procedure Name  : check_la_credit_status
-- Description     : Procedure to check if credit processing has been done on the
--                   Lease Application.
-- Business Rules  : Checks if the Lease Application is in CR-APPROVED or CR-REJECTED
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE check_la_credit_status(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2,
                                   actid IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2) IS

    l_approval_option          VARCHAR2(10);
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'check_la_credit_status';
    l_object_name               VARCHAR2(50);
    l_name                      VARCHAR2(100);
    l_rejected_message          VARCHAR2(500);

    l_la_id OKL_LEASE_APPLICATIONS_B.ID%TYPE;
    l_la_status OKL_LEASE_APPLICATIONS_B.APPLICATION_STATUS%TYPE;

  CURSOR c_get_la_status(cp_la_id OKL_LEASE_APPLICATIONS_B.ID%TYPE) IS
    SELECT LAB.APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B LAB
     WHERE LAB.ID = cp_la_id;

  BEGIN

    IF (funcmode = 'RUN') THEN
      l_la_id := wf_engine.GetItemAttrText(itemtype,
                                                    itemkey,
                                                    'LA_ID');

      OPEN c_get_la_status(l_la_id);
        FETCH c_get_la_status INTO l_la_status;
      CLOSE c_get_la_status;

      IF (l_la_status = 'CR-APPROVED' OR l_la_status = 'CR-REJECTED') THEN
        resultout := 'COMPLETE:YES';

        -- set the attributes in workflow
        get_lease_app_details(itemtype,itemkey);

        --Set the message for rejection
        OPEN obj_name_csr('LAP');
          FETCH obj_name_csr INTO l_object_name;
        CLOSE obj_name_csr;
        l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'LA_NAME');

      wf_engine.SetItemAttrDocument(itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      => G_WF_ITM_MESSAGE_BODY,
                                    documentid => 'plsql:okl_lease_app_wf.get_la_withdraw_msg_doc/' ||
                                    itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_lease_app_msg_body(itemtype,
                                                             itemkey));

        l_rejected_message := get_message('OKL_FE_SALES_CR_DECIDED',
                                        l_object_name,
                                        l_name);

        -- Set the message header
        wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APP_REJECTED_SUB,
                              l_rejected_message);
        wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APP_REJECTED_HEAD,
                              l_rejected_message);

      ELSE
        resultout := 'COMPLETE:NO';
      END IF; -- end of check for credit staus
      RETURN;
    END IF;

    -- CANCEL or TIMEOUT mode
    IF (funcmode = 'CANCEL' OR funcmode = 'TIMEOUT') THEN
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
  END check_la_credit_status;

  -- Start of comments
  --
  -- Procedure Name  : get_lat_ver_details
  -- Description     : Gets the details of the Lease Application Template version
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE get_lat_ver_details (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2,
                                 actid IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'get_lat_ver_details';
  BEGIN
    -- RUN mode
    IF (funcmode = 'RUN') THEN
      -- set the attributes required in the workflow
      get_lat_ver_data(itemtype,itemkey);
      --set the messages
      set_messages(itemtype,itemkey,'LAT');

      RETURN;
    END IF;

    -- CANCEL or TIMEOUT mode
    IF (funcmode = 'CANCEL' OR funcmode = 'TIMEOUT') THEN
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
  END get_lat_ver_details;

  -- Get the details of Lease app and set in the workflow attributes


  -- Start of comments
  --
  -- Procedure Name  : get_la_withdraw_details
  -- Description     : Gets the details of the Lease Application details and
  --                   Sets the message for this operation
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE get_la_withdraw_details (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2,
                                 actid IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'get_la_withdraw_details';

    l_lease_app_id OKL_LEASE_APPLICATIONS_V.ID%TYPE;

  BEGIN
    -- RUN mode
    IF (funcmode = 'RUN') THEN
     -- set the attributes in workflow
     get_lease_app_details(itemtype,itemkey);

      --set the messages for Lease Application identified by lookup code 'LAP'
      set_messages(itemtype,itemkey,'LAP');

      RETURN;
    END IF;

    -- CANCEL or TIMEOUT mode
    IF (funcmode = 'CANCEL' OR funcmode = 'TIMEOUT') THEN
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
  END get_la_withdraw_details;


  -- Start of comments
  --
  -- Procedure Name  : handle_lat_approval
  -- Description     : Handles the process after the process is approved or rejected
  -- Business Rules  : If Approved, call the API to activate the LAT
  --                   Else change the version status of LAT to NEW
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE handle_lat_approval (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2,
                                 actid IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2) IS
    l_api_version              NUMBER   := 1.0;
    l_api_name        CONSTANT VARCHAR2(30) := 'handle_lat_approval';
    l_msg_count                NUMBER;
    l_init_msg_list            VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data                 VARCHAR2(2000);
    l_return_status         VARCHAR2(1);

    l_lat_version_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE;

    l_result                VARCHAR2(30);
    lv_approval_status_ame  VARCHAR2(30);

    l_lavv_rec                 lavv_rec_type;
    lx_lavv_rec                lavv_rec_type;

    CURSOR c_get_ver_dtls ( cp_version_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE) IS
      SELECT LAVV.OBJECT_VERSION_NUMBER
        FROM OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV
       WHERE LAVV.ID = cp_version_id;
  BEGIN
    -- RUN mode
    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');
      -- If the approver has approved
      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN
        l_lat_version_id := wf_engine.GetItemAttrText(itemtype,
                                                      itemkey,
                                                      'VERSION_ID');

        -- Call API to activate the Lease Application template
        OKL_LEASEAPP_TEMPLATE_PVT.activate_lat (
                       p_api_version       => l_api_version
                     , p_init_msg_list     => l_init_msg_list
                     , x_return_status     => l_return_status
                     , x_msg_count         => l_msg_count
                     , x_msg_data          => l_msg_data
                     , p_lat_version_id    => l_lat_version_id);
         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      ELSE -- if the approver has rejected, change the status of version to NEW

        OPEN c_get_ver_dtls(l_lat_version_id);
          FETCH c_get_ver_dtls INTO l_lavv_rec.object_version_number ;
        CLOSE c_get_ver_dtls;
        l_lavv_rec.id              := l_lat_version_id;
        l_lavv_rec.version_status  := G_STATUS_NEW;

        -- call the TAPI insert_row to update lease application template version
        OKL_LAV_PVT.update_row(p_api_version              => l_api_version
                             , p_init_msg_list              => l_init_msg_list
                             , x_return_status              => l_return_status
                             , x_msg_count                  => l_msg_count
                             , x_msg_data                   => l_msg_data
                             , p_lavv_rec                   => l_lavv_rec
                             , x_lavv_rec                   => lx_lavv_rec);
         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      END IF; -- end of check for approval or rejection

      RETURN;
    END IF;

    -- CANCEL or TIMEOUT mode
    IF (funcmode = 'CANCEL' OR funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT(G_PKG_NAME,
                        l_api_version,
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END handle_lat_approval;

  -- Start of comments
  --
  -- Procedure Name  : handle_la_withdraw_approval
  -- Description     : Handles the process after the Lease Application withdrawal
  --                   is approved or rejected by Credit Analyst.
  -- Business Rules  : If Approved, call the API to withdraw the Lease Application
  --                   Else the Lease Application status is not changed.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE handle_la_withdraw_approval (itemtype IN VARCHAR2,
                                           itemkey IN VARCHAR2,
                                           actid IN NUMBER,
                                           funcmode IN VARCHAR2,
                                           resultout OUT NOCOPY VARCHAR2) IS
    l_api_version              NUMBER   := 1.0;
    l_api_name        CONSTANT VARCHAR2(30) := 'handle_la_withdraw_approval';
    l_msg_count                NUMBER;
    l_init_msg_list            VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data                 VARCHAR2(2000);
    l_return_status            VARCHAR2(1);

    lv_approval_status_ame  VARCHAR2(30);
    l_lease_app_id OKL_LEASE_APPLICATIONS_V.ID%TYPE;

  BEGIN
    -- RUN mode
    IF (funcmode = 'RUN') THEN

      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');
      -- If the approver has approved
      IF (lv_approval_status_ame = 'Y') THEN
        l_lease_app_id := wf_engine.GetItemAttrText(itemtype,
                                                    itemkey,
                                                    'LA_ID');

        -- Call API to change the Lease Application status to WITHDRAWN
        OKL_LEASE_APP_PVT.set_lease_app_status(
            p_api_version        => l_api_version,
            p_init_msg_list      => l_init_msg_list,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_lap_id             => l_lease_app_id,
            p_lap_status         => 'WITHDRAWN');
         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      END IF; -- end of check for approval or rejection

      RETURN;
    END IF;

    -- CANCEL or TIMEOUT mode
    IF (funcmode = 'CANCEL' OR funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT(G_PKG_NAME,
                        l_api_version,
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END handle_la_withdraw_approval;

END OKL_LEASE_APP_WF;

/
