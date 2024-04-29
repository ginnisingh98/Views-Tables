--------------------------------------------------------
--  DDL for Package Body OKC_REP_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_WF_PVT" AS
/* $Header: OKCVREPWFB.pls 120.5.12010000.21 2013/12/13 07:03:21 serukull ship $ */

  ---------------------------------------------------------------------------
  -- Global VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_WF_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  G_OBJECT_NAME                CONSTANT   VARCHAR2(200) := 'OKC_REP_CONTRACT';

  G_STATUS_PENDING_APPROVAL    CONSTANT   VARCHAR2(30) :=  'PENDING_APPROVAL';
  G_STATUS_APPROVED            CONSTANT   VARCHAR2(30) :=  'APPROVED';
  G_STATUS_REJECTED            CONSTANT   VARCHAR2(30) :=  'REJECTED';
  G_STATUS_TIMEOUT             CONSTANT   VARCHAR2(30) :=  'TIMEOUT';

  G_ACTION_SUBMITTED           CONSTANT   VARCHAR2(30) :=  'SUBMITTED';

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  -- G_APPROVAL_ITEM_TYPE         CONSTANT   VARCHAR2(200) := 'OKCREPAP';
  -- G_APPROVAL_MASTER_ITEM_TYPE  CONSTANT   VARCHAR2(200) := 'OKCREPMA';
  G_APPROVAL_PROCESS           CONSTANT   VARCHAR2(200) := 'REP_APPROVAL_PROCESS';
  G_APPROVAL_NOTIF_PROCESS     CONSTANT   VARCHAR2(200) := 'APPROVAL_NOTIFICATION';
  G_TRANSACTION_TYPE           CONSTANT   VARCHAR2(200) := 'OKC_REP_CON_APPROVAL';

  G_APPLICATION_ID         CONSTANT   NUMBER := 510;

  G_WF_STATUS_APPROVED         CONSTANT   VARCHAR2(200) := 'APPROVED';
  G_WF_STATUS_REJECTED         CONSTANT   VARCHAR2(200) := 'REJECTED';
  G_WF_STATUS_MORE_APPROVERS   CONSTANT   VARCHAR2(200) := 'OKC_REP_MORE_APPROVERS';
  G_WF_STATUS_TRANSFERRED        CONSTANT   VARCHAR2(200) := 'TRANSFERRED';
  G_WF_STATUS_DELEGATED        CONSTANT   VARCHAR2(200) := 'DELEGATED';

  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    ------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ------------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : initialize_attributes
--Type          : Private.
--Function      : This procedure is called by workflow to initialize workflow attributes.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
  PROCEDURE initialize_attributes(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_api_name      VARCHAR2(30);

    CURSOR contract_csr(l_contract_id NUMBER) IS
        SELECT contract_type, contract_number, contract_name, contract_version_num
        FROM okc_rep_contracts_all
        WHERE contract_id = l_contract_id;

    contract_rec       contract_csr%ROWTYPE;

    l_resolved_token varchar2(250);

    BEGIN

    l_api_name := 'initialize_attributes';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.initialize_attributes');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
    END IF;
    IF (funcmode = 'RUN') THEN
        l_contract_id := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_ID');

      -- Get contract attributes
      OPEN contract_csr(l_contract_id);
      FETCH contract_csr INTO contract_rec;
      IF(contract_csr%NOTFOUND) THEN
               RAISE NO_DATA_FOUND;
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Calling WF_ENGINE.setitemattrnumber for CONTRACT_TYPE ' || contract_rec.contract_type);
      END IF;
      WF_ENGINE.SetItemAttrText (
            itemtype =>  itemtype,
            itemkey  =>  itemkey,
            aname    =>  'CONTRACT_TYPE',
            avalue   =>  contract_rec.contract_type);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.setitemattrnumber for CONTRACT_NUMBER ' || contract_rec.contract_number);
      END IF;
      WF_ENGINE.SetItemAttrText (
            itemtype =>  itemtype,
            itemkey  =>  itemkey,
            aname    =>  'CONTRACT_NUMBER',
            avalue   =>  contract_rec.contract_number);


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.setitemattrnumber for CONTRACT_VERSION_NUM ' || contract_rec.contract_version_num);
      END IF;
      WF_ENGINE.SetItemAttrNumber (
            itemtype =>  itemtype,
            itemkey  =>  itemkey,
            aname    =>  'CONTRACT_VERSION',
            avalue   =>  contract_rec.contract_version_num);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.setitemattrnumber for CONTRACT_NAME ' || contract_rec.contract_name);
      END IF;
      WF_ENGINE.SetItemAttrText (
            itemtype =>  itemtype,
            itemkey  =>  itemkey,
            aname    =>  'CONTRACT_NAME',
            avalue   =>  contract_rec.contract_name);

      l_resolved_token := OKC_API.resolve_hdr_token(contract_rec.contract_type);

IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'Calling WF_ENGINE.setitemattrtext for CONTRACT_HDR_TOKEN  ' || l_resolved_token);
               END IF;


               WF_ENGINE.SetItemAttrText (
               itemtype =>  itemtype,
               itemkey  =>  itemkey,
               aname    =>  'CONTRACT_HDR_TOKEN',
               avalue   =>  l_resolved_token);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.setitemattrnumber for CONTRACT_ATTACHMENTS');
      END IF;
      WF_ENGINE.SetItemAttrText (
            itemtype =>  itemtype,
            itemkey  =>  itemkey,
            aname    =>  'CONTRACT_ATTACHMENTS',
            avalue   =>  'FND:entity=OKC_CONTRACT_DOCS&pk1name=BusinessDocumentType&pk1value='||contract_rec.contract_type
			              ||'&pk2name=BusinessDocumentId&pk2value='||l_contract_id
						  ||'&pk3name=BusinessDocumentVersion&pk3value=-99&categories=OKC_REPO_CONTRACT,OKC_REPO_APP_ABSTRACT');

      -- Initialize AME, clear all prior approvals on this transaction id.
      ame_api2.clearAllApprovals(
            applicationIdIn => G_APPLICATION_ID,
            transactionTypeIn => G_TRANSACTION_TYPE,
            transactionIdIn => fnd_number.number_to_canonical(l_contract_id));

      CLOSE contract_csr;
        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name ,
                 'Leaving OKC_REP_WF_PVT.initialize_attributes from funcmode=RUN');
        END IF;
        RETURN;
    END IF; -- (funcmode = 'RUN')


    IF (funcmode = 'CANCEL') THEN
          resultout := 'COMPLETE:';
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.initialize_attributes from funcmode=CANCEL');
          END IF;
          RETURN;
    END IF; -- (funcmode = 'CANCEL')

    IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:';
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.initialize_attributes from funcmode=TIMEOUT');
          END IF;
          RETURN;
    END IF;  -- (funcmode = 'TIMEOUT')

    EXCEPTION
        WHEN others THEN
          --close cursors
          IF (contract_csr%ISOPEN) THEN
            CLOSE contract_csr ;
          END IF;
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.initialize_attributes with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'initialize_attributes',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;

  END initialize_attributes;

-- Start of comments
--API name      : has_next_approver
--Type          : Private.
--Function      : This procedure is called by workflow to get the next approver in the list. Call AME to get the approver list.
--                Updates workflow with the approver list.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE has_next_approver(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS
    l_api_name          VARCHAR2(30);
    l_contract_id           OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_process_complete_yn   varchar2(1);
    l_next_approvers      ame_util.approversTable2;
    l_item_indexes        ame_util.idList;
    l_item_classes        ame_util.stringList;
    l_item_ids            ame_util.stringList;
    l_item_sources        ame_util.longStringList;
    l_user_names            varchar2(4000);
    l_role_name             varchar2(4000);
    l_role_display_name     varchar2(4000);
    l_contract_hdr_token   VARCHAR2(250);


    BEGIN

    l_api_name := 'has_next_approver';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.has_next_approver');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
    END IF;
    IF (funcmode = 'RUN') then
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling wf_engine.GetItemAttrNumber to get CONTRACT_ID');
        END IF;
        l_contract_id := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_ID');
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Id is: ' || to_char(l_contract_id));
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling ame_api.getNextApprover to get the approver id');
        END IF;
        ame_api2.getNextApprovers1(
              applicationIdIn => G_APPLICATION_ID,
                    transactionTypeIn => G_TRANSACTION_TYPE,
                    transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                    flagApproversAsNotifiedIn => ame_util.booleanFalse,
                    approvalProcessCompleteYNOut => l_process_complete_yn,
                    nextApproversOut => l_next_approvers,
                    itemIndexesOut => l_item_indexes,
                    itemClassesOut => l_item_classes,
                    itemIdsOut => l_item_ids,
                    itemSourcesOut => l_item_sources);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Number of approvers: ' || to_char(l_next_approvers.count));
        END IF;
        IF (l_next_approvers.count = 0) THEN
          -- No more approver.
          wf_engine.SetItemAttrText (
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'APPROVER',
              avalue    => NULL);
          resultout := 'COMPLETE:F';
        ELSIF (l_next_approvers.count = 1) THEN
          -- Only 1 approver remaining
          wf_engine.SetItemAttrText (
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'APPROVER',
              avalue    => l_next_approvers(1).name);
          resultout := 'COMPLETE:T';
        ELSE
          l_user_names := l_next_approvers(1).name;
          -- More than 1 approvers
          -- Concatenate approver names using , separator
          FOR i IN l_next_approvers.first..l_next_approvers.last LOOP
              IF l_next_approvers.exists(i) THEN
                  IF (i=1) THEN
                    l_user_names := l_next_approvers(1).name;
                  ELSE
                    l_user_names := l_user_names || ',' || l_next_approvers(i).name;
                  END IF;
              END IF;
          END LOOP;

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Adhoc role name is : ' || l_user_names);
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling WF_DIRECTORY.createAdHocRole');
          END IF;
          -- Create an adhoc role using l_user_names
          WF_DIRECTORY.createAdHocRole(
           role_name=>l_role_name,
               role_display_name=>l_role_display_name,
               language=>null,
               territory=>null,
               role_description=>'Repository Contract Ad hoc role',
               notification_preference=>'MAILHTML',
               role_users=>l_user_names,
               email_address=>null,
               fax=>null,
               status=>'ACTIVE',
               expiration_date=>SYSDATE+1);
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Completed Adhoc role creation');
          END IF;
          wf_engine.SetItemAttrText (
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'APPROVER',
              avalue    => l_role_name);
          resultout := 'COMPLETE:T';
        END IF;  -- (l_next_approvers.count = 0)

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.has_next_approver from funcmode=RUN');
        END IF;
        RETURN;
      END IF;   -- (funcmode = 'RUN')


      IF (funcmode = 'CANCEL') THEN
          resultout := 'COMPLETE:';
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.has_next_approver from funcmode=CANCEL');
          END IF;
          RETURN;
      END IF;  -- (funcmode = 'CANCEL')

      IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:';
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.has_next_approver from funcmode=TIMEOUT');
          END IF;
          RETURN;
      END IF;  -- (funcmode = 'TIMEOUT')

      EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.has_next_approver with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'has_next_approver',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;

    END has_next_approver;


-- Start of comments
--API name      : is_approval_complete
--Type          : Private.
--Function      : This procedure is called by workflow Master Process to check if the approval is complete.
--                WF Notification process are started for the approvers pending notification
--                Updates workflow with the approver list.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE is_approval_complete(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS
    l_api_name              varchar2(30);
    l_contract_id           OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_contract_number       OKC_REP_CONTRACTS_ALL.contract_number%type;
    l_requester             varchar2(4000);
    l_contract_type         OKC_REP_CONTRACTS_ALL.contract_type%type;
    l_contract_version      OKC_REP_CONTRACTS_ALL.contract_version_num%type;
    l_contract_name         OKC_REP_CONTRACTS_ALL.contract_name%type;
    l_contract_attachments  varchar2(4000);
    l_process_complete_yn   varchar2(1);
    l_next_approvers      ame_util.approversTable2;
    l_item_indexes        ame_util.idList;
    l_item_classes        ame_util.stringList;
    l_item_ids            ame_util.stringList;
    l_item_sources        ame_util.longStringList;
    l_user_name           varchar2(4000);
    l_role_name           varchar2(4000);
    l_role_display_name   varchar2(4000);
    l_item_key            wf_items.item_key%TYPE;
    l_notified_count      number;

    l_approver_name VARCHAR2(100);
    l_approver_type VARCHAR2(100);
    l_group_id      NUMBER; --Bug 16231003
    l_contract_hdr_token   VARCHAR2(250);

    BEGIN

    l_api_name := 'is_approval_complete';


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.is_approval_complete');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
    END IF;
    IF (funcmode = 'RUN') then
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling wf_engine.GetItemAttrNumber to get CONTRACT_ID');
        END IF;
        l_contract_id := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_ID');
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Id is: ' || to_char(l_contract_id));
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling ame_api2.getNextApprover1 to get the approver id');
        END IF;
        ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;
        ame_api2.getNextApprovers1(
              applicationIdIn => G_APPLICATION_ID,
                    transactionTypeIn => G_TRANSACTION_TYPE,
                    transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                    flagApproversAsNotifiedIn => ame_util.booleanTrue,
                    approvalProcessCompleteYNOut => l_process_complete_yn,
                    nextApproversOut => l_next_approvers,
                    itemIndexesOut => l_item_indexes,
                    itemClassesOut => l_item_classes,
                    itemIdsOut => l_item_ids,
                    itemSourcesOut => l_item_sources);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Number of approvers: ' || to_char(l_next_approvers.count));
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'l_process_complete_yn: ' || l_process_complete_yn);
        END IF;
        IF (l_process_complete_yn = 'W') THEN
        	resultout := 'COMPLETE:F';
        ELSE
        	resultout := 'COMPLETE:T';
        END IF;

        IF (l_next_approvers.count > 0) THEN
          l_contract_number := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_NUMBER');
          l_requester := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'REQUESTER');
          l_contract_name := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_NAME');
          l_contract_version := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_VERSION');
          l_contract_type := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_TYPE');
          l_notified_count := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'APPROVER_COUNTER');
           l_contract_hdr_token := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_HDR_TOKEN');
          FOR i IN l_next_approvers.first..l_next_approvers.last LOOP
              IF l_next_approvers.exists(i) THEN
             --kkolukul : Change code to support HR positions approval hierarchy
               l_approver_type := l_next_approvers(i).orig_system;

                IF (l_next_approvers(i).orig_system = ame_util.posOrigSystem) THEN

                BEGIN
                  -----------------------------------------------------------------------
		              -- SQL What: Get the person assigned to position returned by AME.
                      -- SQL Why : When AME returns position id, then using this sql we find
                      --           one person assigned to this position and use this person
		              --           as approver.
                  -----------------------------------------------------------------------
                  l_approver_name :=  l_next_approvers(i).name;
                  --Bug 16231003
                  l_group_id      :=  l_next_approvers(i).group_or_chain_id;


                    SELECT user_name INTO l_user_name
                    FROM (
                          SELECT user_name FROM fnd_user fu, per_all_assignments_f asg,  per_all_people_f per
                          WHERE asg.position_id =  l_next_approvers (i).orig_system_id
                          AND per.person_id = asg.person_id
                          AND fu.employee_id = per.person_id
                          AND TRUNC(SYSDATE) BETWEEN per.effective_start_date AND NVL(per.effective_end_date, TRUNC( SYSDATE))
                          AND asg.primary_flag = 'Y'
                          AND asg.assignment_type IN ( 'E', 'C' )
                          AND ( per.current_employee_flag = 'Y' OR per.current_npw_flag = 'Y' )
                          AND asg.assignment_status_type_id NOT IN
                                                                ( SELECT assignment_status_type_id
                                                                  FROM per_assignment_status_types
                                                                  WHERE per_system_status = 'TERM_ASSIGN' )
                          AND TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
                          ORDER BY per.last_name  )
                    WHERE ROWNUM = 1;

                            EXCEPTION
                              WHEN NO_DATA_FOUND THEN

                                -- As this is a blank record, remove it in AME and the global variable.
                                -- Return 'NO_USERS'. We use PO_SYS_GENERATED_APPROVERS_SUPPRESS dynamic profile to
		                -- override AME mandatory attribute  ALLOW_DELETING_RULE_GENERATED_APPROVERS.
	                                    ame_api3.suppressApprover( applicationIdIn    => G_APPLICATION_ID,
                                                          transactionIdIn    => fnd_number.number_to_canonical(l_contract_id),
                                                          approverIn         => l_next_approvers(i),
                                                          transactionTypeIn  => G_TRANSACTION_TYPE );
                              --  l_next_approvers.delete(i);
                             --   l_position_has_valid_approvers := 'NO_USERS';
                             IF i = l_next_approvers.Count THEN
                               resultout := 'COMPLETE:F'  ;
                             EXIT;

                             ELSE
                              CONTINUE;
                             END IF;
                  END;

                ELSE
                  l_user_name := l_next_approvers(i).name;
                  --Bug 16231003
                  l_group_id      :=  l_next_approvers(i).group_or_chain_id;




                END IF; --g_next_approvers(l_approver_index).orig_system = ame_util.posOrigSystem

                 -- l_user_name := l_next_approvers(i).name;
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  	fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       g_module || l_api_name,
                      'User name for role is : ' || l_user_name);
                  END IF;
                  l_notified_count := l_notified_count + 1;
                  l_item_key := itemkey || '_' || to_char(l_notified_count);
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Calling WF_ENGINE.createprocess for Notification');
                  END IF;

                  WF_ENGINE.createprocess (
                    itemtype => itemtype,
                    itemkey  => l_item_key,
                    process  => G_APPROVAL_NOTIF_PROCESS);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Calling WF_ENGINE.SetItemOwner for Notification Process');
                  END IF;
                  WF_ENGINE.SetItemOwner (
                    itemtype => itemtype,
                    itemkey  => l_item_key,
                    owner    => fnd_global.user_name);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Approver to: ' || l_user_name);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'APPROVER',
                      avalue    => l_user_name);


                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Contract Id to: ' || l_contract_id);
                  END IF;
                  WF_ENGINE.SetItemAttrNumber (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'CONTRACT_ID',
                      avalue    => l_contract_id);

                   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Setting Notification Process Contract Header Token to: ' || l_contract_hdr_token);
                  END IF;

                  WF_ENGINE.SetItemAttrText (
                      itemtype =>  itemtype,
                      itemkey  =>  l_item_key,
                      aname    =>  'CONTRACT_HDR_TOKEN',
                      avalue   =>  l_contract_hdr_token);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Contract Name: ' || l_contract_name);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'CONTRACT_NAME',
                      avalue    => l_contract_name);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Contract Version: ' || l_contract_version);
                  END IF;
                  WF_ENGINE.SetItemAttrNumber (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'CONTRACT_VERSION',
                      avalue    => l_contract_version);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Contract Type: ' || l_contract_type);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'CONTRACT_TYPE',
                      avalue    => l_contract_type);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Contract Number: ' || l_contract_number);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'CONTRACT_NUMBER',
                      avalue    => l_contract_number);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Requester: ' || l_requester);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'REQUESTER',
                      avalue    => l_requester);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Contract Attachment');
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'CONTRACT_ATTACHMENTS',
                      avalue   =>  'FND:entity=OKC_CONTRACT_DOCS&pk1name=BusinessDocumentType&pk1value='||l_contract_type
			              ||'&pk2name=BusinessDocumentId&pk2value='||l_contract_id
						  ||'&pk3name=BusinessDocumentVersion&pk3value=-99&categories=OKC_REPO_CONTRACT,OKC_REPO_APP_ABSTRACT');

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Master Item Key to: ' || itemkey);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'MASTER_ITEM_KEY',
                      avalue    => itemkey);

                  --14758583 : kkolukul : HR position group support
 	                  --Setting attributes for the parent process
 	                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
 	                  'Setting Notification Process APPROVER_TYPE to: ' || l_approver_type);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
 	                  itemtype  => itemtype,
 	                  itemkey   => itemkey,
 	                  aname     => 'APPROVER_TYPE',
 	                  avalue    => l_approver_type);

 	                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
 	                  'Setting Notification Process APPROVER_POS_NAME to: ' || l_approver_name);
 	                END IF;

 	                WF_ENGINE.SetItemAttrText (
 	                  itemtype  => itemtype,
 	                  itemkey   => itemkey,
 	                  aname     => 'APPROVER_POS_NAME',
 	                  avalue    => l_approver_name);


                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Approver group Id to: ' || l_group_id);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'APPROVER_GROUP_ID',
                      avalue    => l_group_id);


 	                  --Setting attributes for the child notification process
 	                WF_ENGINE.SetItemAttrText (
 	                  itemtype  => itemtype,
 	                  itemkey   => l_item_key,
 	                  aname     => 'APPROVER_TYPE',
 	                  avalue    => l_approver_type);

 	                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
 	                  'Setting Notification Process APPROVER_POS_NAME to: ' || l_approver_name);
 	                END IF;

 	                WF_ENGINE.SetItemAttrText (
 	                  itemtype  => itemtype,
 	                  itemkey   => l_item_key,
 	                  aname     => 'APPROVER_POS_NAME',
 	                  avalue    => l_approver_name);

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Setting Notification Process Approver group Id to: ' || l_group_id);
                  END IF;
                  WF_ENGINE.SetItemAttrText (
                      itemtype  => itemtype,
                      itemkey   => l_item_key,
                      aname     => 'APPROVER_GROUP_ID',
                      avalue    => l_group_id);


 	                  --14758583 : kkolukul : HR position group support

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Starting Notification Process ');
                  END IF;
                  wf_engine.startProcess(
                      itemtype  => itemtype,
                      itemkey   => l_item_key);
                END IF;  -- l_next_approvers.exists(i)
           END LOOP;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.setitemattrnumber for APPROVER_COUNTER: ' || l_notified_count);
           END IF;
           WF_ENGINE.SetItemAttrNumber (
              itemtype =>  itemtype,
              itemkey  =>  itemkey,
              aname    =>  'APPROVER_COUNTER',
              avalue   =>  l_notified_count);
        END IF;   -- (l_next_approvers.count > 0)

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_approval_complete from funcmode=RUN');
        END IF;
        RETURN;
      END IF;   -- (funcmode = 'RUN')


      IF (funcmode = 'CANCEL') THEN
          resultout := 'COMPLETE:';
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_approval_complete from funcmode=CANCEL');
          END IF;
          RETURN;
      END IF;  -- (funcmode = 'CANCEL')

      IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:';
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_approval_complete from funcmode=TIMEOUT');
          END IF;
          RETURN;
      END IF;  -- (funcmode = 'TIMEOUT')

      EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_approval_complete with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'is_approval_complete',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;

    END is_approval_complete;



-- Start of comments
--API name      : update_ame_status
--Type          : Private.
--Function      : This procedure is called by workflow after each approver's response.
--                Updates AME approver's approval status, updates Contract's approval hisotry,
--                Calls ame_api2.getNextApprovers1 to check if more approvers exists. Return
--                COMPLETE:APPROVED if last approver approved the contract,
--                COMPLETE:REJECTED if current approver rejected the contract, COMPLETE: if more
--                exist for this contract approvers.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE update_ame_status(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CON_APPROVALS.contract_id%type;
    l_contract_version  OKC_REP_CON_APPROVALS.contract_version_num%type;
    l_approver_record2  ame_util.approverRecord2;
    l_approver_id       number;
    l_approval_status   VARCHAR2(30);
    l_recipient_name    FND_USER.user_name%type;
    l_action_code       OKC_REP_CON_APPROVALS.action_code%type;
    l_wf_note           VARCHAR2(2000);
    l_api_name          VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_process_complete_yn   varchar2(1);
    l_next_approvers        ame_util.approversTable2;
    l_item_indexes          ame_util.idList;
    l_item_classes          ame_util.stringList;
    l_item_class_names      ame_util.stringList;
    l_item_ids              ame_util.stringList;
    l_item_sources          ame_util.longStringList;

    l_approver_type      VARCHAR2(100);
    l_approver_name     VARCHAR2(100);

    CURSOR  notif_csr  (p_notification_id NUMBER) IS
        SELECT fu.user_id user_id, fu.user_name user_name,
	fu1.user_id original_user_id,fu1.user_name original_user_name
        FROM   fnd_user fu, wf_notifications wfn, fnd_user fu1
        WHERE  fu.user_name = wfn.recipient_role
	AND    fu1.user_name = wfn.original_recipient
        AND    wfn.notification_id = p_notification_id ;

    notif_rec  notif_csr%ROWTYPE;

    BEGIN

    l_api_name := 'update_ame_status';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.update_ame_status');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;
      -- Get contract id and version attributes
      l_contract_id := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_ID');
      l_contract_version := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_VERSION');
      -- Get the approver comments
      l_wf_note := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'WF_NOTE');
      -- Get the approval status
      l_approval_status := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'RESULT');
       --14758583  : kkolukul : HR position support
      l_approver_type :=  WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'APPROVER_TYPE');
      l_approver_name := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'APPROVER_POS_NAME');

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Contract Id is: ' || to_char(l_contract_id));
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Contract Version is: ' || to_char(l_contract_version));
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver Notes : ' || l_wf_note);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver action is : ' || l_approval_status);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver Type is : ' || l_approver_type);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver Name is : ' || l_approver_name);
      END IF;
      -- Get the notification recipient
      OPEN notif_csr(WF_ENGINE.context_nid);
      FETCH notif_csr into notif_rec;
      IF(notif_csr%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
      END IF;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            g_module || l_api_name,
            'Approver Name is : ' || notif_rec.user_name);
      END IF;
--      l_approver_record2.name := notif_rec.user_name;
	--14758583  : kkolukul : HR position support
          IF (l_approver_type = ame_util.posOrigSystem) THEN
            l_approver_record2.name :=  l_approver_name;
          ELSE
            l_approver_record2.name := notif_rec.original_user_name;
          END IF;
      -- FUNCTION MODE IS RESPOND.
      IF (funcmode = 'RESPOND') THEN
        -- CURRENT APPROVER APPROVED THE CONTRACTS
        IF (l_approval_status = G_WF_STATUS_APPROVED) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Approver action is : ' || G_WF_STATUS_APPROVED);
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
            END IF;
            OKC_REP_UTIL_PVT.add_approval_hist_record(
                p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_contract_id         => l_contract_id,
                p_contract_version    => l_contract_version,
                p_action_code         => G_STATUS_APPROVED,
                p_user_id             => notif_rec.user_id,
                p_note                => l_wf_note,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count,
                x_return_status       => l_return_status);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
            END IF;
            -------------------------------------------------------
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            --------------------------------------------------------
            l_approver_record2.approval_status := ame_util.approvedStatus;
                ame_api2.updateApprovalStatus(
                applicationIdIn => G_APPLICATION_ID,
                transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                approverIn => l_approver_record2,
                transactionTypeIn => G_TRANSACTION_TYPE);
            -- resultout := 'COMPLETE:'  || G_WF_STATUS_APPROVED;

        -- CURRENT APPROVER APPROVED THE CONTRACTS
        ELSIF (l_approval_status = G_WF_STATUS_REJECTED) THEN
            -- Add a record in ONC_REP_CON_APPROVALS table.
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Approver action is : ' || G_WF_STATUS_REJECTED);
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
            END IF;
            OKC_REP_UTIL_PVT.add_approval_hist_record(
                p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_contract_id         => l_contract_id,
                p_contract_version    => l_contract_version,
                p_action_code         => G_STATUS_REJECTED,
                p_user_id             => notif_rec.user_id,
                p_note                => l_wf_note,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count,
                x_return_status       => l_return_status);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
            END IF;
            -------------------------------------------------------
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            --------------------------------------------------------

            l_approver_record2.approval_status := ame_util.rejectStatus;
            -- Update AME approval status
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling ame_api2.updateApprovalStatus');
            END IF;
            ame_api2.updateApprovalStatus(
                applicationIdIn => G_APPLICATION_ID,
                transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                approverIn => l_approver_record2,
                transactionTypeIn => G_TRANSACTION_TYPE);
        END IF; -- (l_approval_status = G_WF_STATUS_APPROVED)
        CLOSE notif_csr;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'resultout value is: ' || resultout);
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'Leaving OKC_REP_WF_PVT.update_ame_status from funcmode=RESPOND');
         END IF;
      END IF;    -- (funcmode = 'RESPOND')


      IF (funcmode = 'RUN') THEN
        IF (l_approval_status = G_WF_STATUS_APPROVED) THEN
          resultout := 'COMPLETE:'  || G_WF_STATUS_APPROVED;
        ELSIF (l_approval_status = G_WF_STATUS_REJECTED) THEN
          resultout := 'COMPLETE:'  || G_WF_STATUS_REJECTED;
        ELSIF (l_approval_status = G_WF_STATUS_MORE_APPROVERS) THEN
          resultout := 'COMPLETE:'  || G_WF_STATUS_MORE_APPROVERS;
        ELSE resultout := 'COMPLETE:';
        END IF;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.update_ame_status from funcmode=RUN');
        END IF;
        CLOSE notif_csr;
        RETURN;
      END IF; -- (funcmode = 'RUN')

      IF (funcmode = 'TIMEOUT') THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE, g_module || l_api_name,
                'In OKC_REP_WF_PVT.update_ame_status funcmode=TIMEOUT');
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,g_module || l_api_name,
                'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
        END IF;
        OKC_REP_UTIL_PVT.add_approval_hist_record(
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_contract_id         => l_contract_id,
            p_contract_version    => l_contract_version,
            p_action_code         => G_STATUS_TIMEOUT,
            p_user_id             => notif_rec.user_id,
            p_note                => l_wf_note,
            x_msg_data            => l_msg_data,
            x_msg_count           => l_msg_count,
            x_return_status       => l_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            g_module || l_api_name,
            'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
        END IF;
        -------------------------------------------------------
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        --------------------------------------------------------
        l_approver_record2.approval_status := ame_util.noResponseStatus;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             g_module || l_api_name,
             'Calling ame_api2.updateApprovalStatus');
        END IF;
        ame_api2.updateApprovalStatus(
             applicationIdIn => G_APPLICATION_ID,
             transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
             approverIn => l_approver_record2,
             transactionTypeIn => G_TRANSACTION_TYPE);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.update_ame_status from funcmode=TIMEOUT');
        END IF;
        resultout := 'COMPLETE:';
        CLOSE notif_csr;
        RETURN;
    END IF;   -- (funcmode = 'TIMEOUT')

    exception
        when others then
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 '618: Leaving OKC_REP_WF_PVT.update_ame_status with exceptions ' || sqlerrm);
          END IF;
          --close cursors
          IF (notif_csr%ISOPEN) THEN
            CLOSE notif_csr ;
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'update_ame_status',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END update_ame_status;


-- Start of comments
--API name      : update_ame_status_detailed
--Type          : Private.
--Function      : Same as updated_ame_status. This API calls ame_api6.updateApprovalStatus to update the notification
--                text as well.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE update_ame_status_detailed(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CON_APPROVALS.contract_id%type;
    l_contract_version  OKC_REP_CON_APPROVALS.contract_version_num%type;
    l_approver_record2  ame_util.approverRecord2;
    l_notification_record ame_util2.notificationRecord;
    l_approver_id       number;
    l_approval_status   VARCHAR2(30);
    l_recipient_name    FND_USER.user_name%type;
    l_action_code       OKC_REP_CON_APPROVALS.action_code%type;
    l_wf_note           VARCHAR2(2000);
    l_api_name          VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_process_complete_yn   varchar2(1);
    l_next_approvers        ame_util.approversTable2;
    l_item_indexes          ame_util.idList;
    l_item_classes          ame_util.stringList;
    l_item_class_names      ame_util.stringList;
    l_item_ids              ame_util.stringList;
    l_item_sources          ame_util.longStringList;

    l_action_code_fwd VARCHAR2(250);
    l_recipient_id NUMBER;
    l_recipient_record2  ame_util.approverRecord2;
    l_approver_type      VARCHAR2(100);
    l_approver_name     VARCHAR2(100);

    CURSOR  notif_csr  (p_notification_id NUMBER) IS
        SELECT fu.user_id user_id, fu.user_name user_name,
	fu1.user_id original_user_id,fu1.user_name original_user_name
        FROM   fnd_user fu, wf_notifications wfn, fnd_user fu1
        WHERE  fu.user_name = wfn.recipient_role
	AND    fu1.user_name = wfn.original_recipient
        AND    wfn.notification_id = p_notification_id ;

    notif_rec  notif_csr%ROWTYPE;
 --Bug 16231003
    l_group_id NUMBER;

    BEGIN

    l_api_name := 'update_ame_status';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.update_ame_status_detailed');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;
      -- Get contract id and version attributes
      l_contract_id := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_ID');
      l_contract_version := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_VERSION');
      -- Get the approver comments
      l_wf_note := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'WF_NOTE');
      -- Get the approval status
      l_approval_status := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'RESULT');
      -- 14758583 : kkolukul : HR position support
      l_approver_type :=  WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'APPROVER_TYPE');
      l_approver_name := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'APPROVER_POS_NAME');

--Bug 16231003
      l_group_id := WF_NOTIFICATION.GetAttrText(
            nid       => WF_ENGINE.context_nid,
            aname     => 'APPROVER_GROUP_ID');

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Contract Id is: ' || to_char(l_contract_id));
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Contract Version is: ' || to_char(l_contract_version));
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver Notes : ' || l_wf_note);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver action is : ' || l_approval_status);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver type is : ' || l_approver_type);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver pos name  is : ' || l_approver_name);
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               g_module || l_api_name,
               'Approver group Id  is : ' || l_group_id);

      END IF;
      -- Get the notification recipient
      OPEN notif_csr(WF_ENGINE.context_nid);
      FETCH notif_csr into notif_rec;
      IF(notif_csr%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
      END IF;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            g_module || l_api_name,
            'Approver Name is : ' || notif_rec.user_name);
      END IF;
--      l_approver_record2.name := notif_rec.user_name;
      -- 14758583 : kkolukul : HR position support
      IF (l_approver_type = ame_util.posOrigSystem) THEN
          l_approver_record2.name :=  l_approver_name;
      ELSE
          l_approver_record2.name := notif_rec.original_user_name;
      END IF;
      --Bug 16231003

      l_approver_record2.group_or_chain_id := l_group_id;
      l_notification_record.notification_id := WF_ENGINE.context_nid;
      l_notification_record.user_comments := l_wf_note;
      -- FUNCTION MODE IS RESPOND.
      IF (funcmode = 'RESPOND') THEN
        -- CURRENT APPROVER APPROVED THE CONTRACTS
        IF (l_approval_status = G_WF_STATUS_APPROVED) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Approver action is : ' || G_WF_STATUS_APPROVED);
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
            END IF;
            OKC_REP_UTIL_PVT.add_approval_hist_record(
                p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_contract_id         => l_contract_id,
                p_contract_version    => l_contract_version,
                p_action_code         => G_STATUS_APPROVED,
                p_user_id             => notif_rec.user_id,
                p_note                => l_wf_note,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count,
                x_return_status       => l_return_status);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
            END IF;
            -------------------------------------------------------
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            --------------------------------------------------------
            l_approver_record2.approval_status := ame_util.approvedStatus;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling ame_api6.updateApprovalStatus');
            END IF;
                ame_api6.updateApprovalStatus(
                applicationIdIn => G_APPLICATION_ID,
                transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                approverIn => l_approver_record2,
                transactionTypeIn => G_TRANSACTION_TYPE,
				notificationIn => l_notification_record);
            -- resultout := 'COMPLETE:'  || G_WF_STATUS_APPROVED;

        -- CURRENT APPROVER APPROVED THE CONTRACTS
        ELSIF (l_approval_status = G_WF_STATUS_REJECTED) THEN
            -- Add a record in ONC_REP_CON_APPROVALS table.
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Approver action is : ' || G_WF_STATUS_REJECTED);
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
            END IF;
            OKC_REP_UTIL_PVT.add_approval_hist_record(
                p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_contract_id         => l_contract_id,
                p_contract_version    => l_contract_version,
                p_action_code         => G_STATUS_REJECTED,
                p_user_id             => notif_rec.user_id,
                p_note                => l_wf_note,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count,
                x_return_status       => l_return_status);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
            END IF;
            -------------------------------------------------------
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            --------------------------------------------------------

            l_approver_record2.approval_status := ame_util.rejectStatus;
            -- Update AME approval status
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling ame_api6.updateApprovalStatus');
            END IF;
           ame_api6.updateApprovalStatus(
                applicationIdIn => G_APPLICATION_ID,
                transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                approverIn => l_approver_record2,
                transactionTypeIn => G_TRANSACTION_TYPE,
				notificationIn => l_notification_record);
        END IF; -- (l_approval_status = G_WF_STATUS_APPROVED)
        CLOSE notif_csr;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'resultout value is: ' || resultout);
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'Leaving OKC_REP_WF_PVT.update_ame_status_detailed from funcmode=RESPOND');
         END IF;
      END IF;    -- (funcmode = 'RESPOND')


      IF (funcmode = 'RUN') THEN
        IF (l_approval_status = G_WF_STATUS_APPROVED) THEN
          resultout := 'COMPLETE:'  || G_WF_STATUS_APPROVED;
        ELSIF (l_approval_status = G_WF_STATUS_REJECTED) THEN
          resultout := 'COMPLETE:'  || G_WF_STATUS_REJECTED;
        ELSIF (l_approval_status = G_WF_STATUS_MORE_APPROVERS) THEN
          resultout := 'COMPLETE:'  || G_WF_STATUS_MORE_APPROVERS;
        ELSE resultout := 'COMPLETE:';
        END IF;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.update_ame_status_detailed from funcmode=RUN');
        END IF;
        CLOSE notif_csr;
        RETURN;
      END IF; -- (funcmode = 'RUN')

      IF (funcmode = 'TIMEOUT') THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE, g_module || l_api_name,
                'In OKC_REP_WF_PVT.update_ame_status funcmode=TIMEOUT');
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,g_module || l_api_name,
                'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
        END IF;
        OKC_REP_UTIL_PVT.add_approval_hist_record(
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_contract_id         => l_contract_id,
            p_contract_version    => l_contract_version,
            p_action_code         => G_STATUS_TIMEOUT,
            p_user_id             => notif_rec.user_id,
            p_note                => l_wf_note,
            x_msg_data            => l_msg_data,
            x_msg_count           => l_msg_count,
            x_return_status       => l_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            g_module || l_api_name,
            'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
        END IF;
        -------------------------------------------------------
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        --------------------------------------------------------
        l_approver_record2.approval_status := ame_util.noResponseStatus;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             g_module || l_api_name,
             'Calling ame_api6.updateApprovalStatus');
        END IF;
        ame_api6.updateApprovalStatus(
                applicationIdIn => G_APPLICATION_ID,
                transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                approverIn => l_approver_record2,
                transactionTypeIn => G_TRANSACTION_TYPE,
				notificationIn => l_notification_record);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.update_ame_status_detailed from funcmode=TIMEOUT');
        END IF;
        resultout := 'COMPLETE:';
        CLOSE notif_csr;
        RETURN;
    END IF;   -- (funcmode = 'TIMEOUT')

 --kkolukul: 9825586 - Huaweii ER
      IF  (funcmode = 'FORWARD' OR funcmode = 'TRANSFER') THEN
        l_recipient_record2.name := wf_engine.context_new_role;

        SELECT user_id INTO l_recipient_id
          FROM fnd_user
          WHERE user_name =  l_recipient_record2.name;
        --l_recipient_record2.name := l_recipient;

        l_wf_note:=WF_ENGINE.CONTEXT_USER_COMMENT;
        l_notification_record.notification_id := WF_ENGINE.context_nid;
        l_notification_record.user_comments := l_wf_note;

        IF funcmode = 'FORWARD' THEN
          l_action_code         := G_WF_STATUS_DELEGATED;
        ELSIF funcmode = 'TRANSFER' THEN
          l_action_code         := G_WF_STATUS_TRANSFERRED;
	  l_approver_record2.approval_status := ame_util.forwardStatus;
        END IF;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                  'Approver action is : ' || l_action_code);
                fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                  'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
            END IF;
            OKC_REP_UTIL_PVT.add_approval_hist_record(
                p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_contract_id         => l_contract_id,
                p_contract_version    => l_contract_version,
                p_action_code         => l_action_code,
                p_user_id             => notif_rec.user_id,
                p_note                => l_wf_note,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count,
                x_return_status       => l_return_status,
                p_forward_user_id     => l_recipient_id);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.add_approval_hist_record with return status: ' || l_return_status);
            END IF;

            -------------------------------------------------------
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            --------------------------------------------------------

            -- l_approver_record2.approval_status := ame_util.forwardStatus;
            -- Update AME approval status
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Calling ame_api6.updateApprovalStatus');
            END IF;
           ame_api6.updateApprovalStatus(
                applicationIdIn => G_APPLICATION_ID,
                transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                approverIn => l_approver_record2,
                transactionTypeIn => G_TRANSACTION_TYPE,
        				notificationIn => l_notification_record,
                forwardeeIn => l_recipient_record2);

          CLOSE notif_csr;
              RETURN;

      END IF;   --(funcmode = 'FORWARD')

    exception
        when others then
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 '618: Leaving OKC_REP_WF_PVT.update_ame_status_detailed with exceptions ' || sqlerrm);
          END IF;
          --close cursors
          IF (notif_csr%ISOPEN) THEN
            CLOSE notif_csr ;
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'update_ame_status_detailed',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END update_ame_status_detailed;






-- Start of comments
--API name      : approve_contract
--Type          : Private.
--Function      : This procedure is called by workflow after the contract is approved. Updates Contract's status
--                to approved and logs the status change in OKC_REP_CON_STATUS_HIST table.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE approve_contract(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_contract_version       OKC_REP_CONTRACTS_ALL.contract_version_num%type;
    l_api_name      VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_contract_type    VARCHAR2(30);
    l_latest_ver     NUMBER;
    l_sync_flag      VARCHAR2(1);
    l_activate_event_tbl      EVENT_TBL_TYPE;
    l_update_event_tbl        EVENT_TBL_TYPE;
    l_exp_date     DATE;
    l_eff_date     DATE;
    l_ver         NUMBER;
    l_prev_signed_expiration_date OKC_REP_CONTRACTS_ALL.CONTRACT_EXPIRATION_DATE%TYPE;
    l_prev_signed_effective_date  OKC_REP_CONTRACTS_ALL.CONTRACT_EXPIRATION_DATE%TYPE;
    l_expiration_date_matches_flag VARCHAR2(1);
    l_effective_date_matches_flag  VARCHAR2(1);
    l_contract_number   OKC_REP_CONTRACTS_ALL.contract_number%TYPE;


      CURSOR arch_contract_csr (l_contract_version NUMBER, l_contract_id NUMBER) IS
      SELECT contract_effective_date, contract_expiration_date
      FROM OKC_REP_CONTRACT_VERS
      WHERE contract_id = l_contract_id
      AND contract_version_num = l_contract_version;

    arch_contract_rec  arch_contract_csr%ROWTYPE;


    BEGIN

    l_api_name := 'approve_contract';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.approve_contract');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;
      IF (funcmode = 'RUN') THEN
        l_contract_id := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_ID');
        l_contract_version := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_VERSION');
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Id is: ' || to_char(l_contract_id));
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Version is: ' || to_char(l_contract_version));
        END IF;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.change_contract_status');
        END IF;
        -- Update the contract status and add a record in OKC_REP_CON_STATUS_HIST table.
        OKC_REP_UTIL_PVT.change_contract_status(
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_contract_id         => l_contract_id,
          p_contract_version    => l_contract_version,
          p_status_code         => G_STATUS_APPROVED,
          p_user_id             => fnd_global.user_id,
          p_note                => NULL,
          x_msg_data            => l_msg_data,
          x_msg_count           => l_msg_count,
          x_return_status       => l_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.change_contract_status with return status: ' || l_return_status);
        END IF;
      -----------------------------------------------------
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      --------------------------------------------------------
        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.approve_contract');
        END IF;

	   -- Activating the Deliverables if Contract Type is Acquisition Plan Summary
  SELECT contract_type into l_contract_type from okc_rep_contracts_all where contract_id = l_contract_id;
  --SELECT latest_signed_ver_number into l_latest_ver from okc_rep_contracts_all where contract_id = l_contract_id;
  SELECT contract_expiration_date into l_exp_date from okc_rep_contracts_all where contract_id = l_contract_id;
 -- SELECT contract_version_num into l_ver from okc_rep_contracts_all where contract_id = l_contract_id;
  SELECT contract_effective_date into l_eff_date from okc_rep_contracts_all where contract_id = l_contract_id;

  l_latest_ver := l_contract_version -1;


  IF (l_contract_type = 'REP_ACQ') THEN

   -- We need to first version the deliverables
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_DELIVERABLE_PROCESS_PVT.version_deliverables');
    END IF;
  OKC_DELIVERABLE_PROCESS_PVT.version_deliverables (
      p_api_version         => 1.0,
      p_init_msg_list             => FND_API.G_FALSE,
      p_doc_id                    => l_contract_id,
        p_doc_version               => l_contract_version,
        p_doc_type                  => l_contract_type,
      x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data
        );
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.version_deliverables return status is : '
            || l_return_status);
     END IF;
     -----------------------------------------------------
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Latest signed version number is (approved for ACQ) : '
            || l_latest_ver);
     END IF;
    -- Now we need to activate deliverables
    if (l_contract_version > 1) THEN
      l_sync_flag := FND_API.G_TRUE;
    ELSE
      l_sync_flag := FND_API.G_FALSE;

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_sync_flag is : ' || l_sync_flag);
    END IF;
    l_activate_event_tbl(1).event_code := G_CONTRACT_EXPIRE_EVENT;
    l_activate_event_tbl(1).event_date := l_exp_date;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables');
    END IF;

    OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables (
        p_api_version                 => 1.0,
        p_init_msg_list               => FND_API.G_FALSE,
        p_commit                    => FND_API.G_FALSE,
        p_bus_doc_id                  => l_contract_id,
        p_bus_doc_type                => l_contract_type,
        p_bus_doc_version             => l_contract_version,
        p_event_code                  => G_CONTRACT_EFFECTIVE_EVENT,
        p_event_date                  => l_eff_date,
        p_sync_flag                   => l_sync_flag,
        p_bus_doc_date_events_tbl     => l_activate_event_tbl,
        x_msg_data                    => l_msg_data,
        x_msg_count                   => l_msg_count,
        x_return_status               => l_return_status);

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.activateDeliverables return status is : '
            || l_return_status);
     END IF;
     -----------------------------------------------------
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    -- Checking if we need to call deliverable's APIs for synch-ing
    IF (l_sync_flag = FND_API.G_TRUE) THEN
        -- Get the previous signed contract's expiration date
        -- Get effective dates and version of the contract.
        OPEN arch_contract_csr(l_latest_ver, l_contract_id);
        FETCH arch_contract_csr INTO arch_contract_rec;
        IF(arch_contract_csr%NOTFOUND) THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| l_contract_id);
            END IF;
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(l_contract_id));
            RAISE FND_API.G_EXC_ERROR;
            -- RAISE NO_DATA_FOUND;
        END IF;
        l_prev_signed_effective_date := arch_contract_rec.contract_effective_date;
        l_prev_signed_expiration_date := arch_contract_rec.contract_expiration_date;

        CLOSE arch_contract_csr;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Before checking if we need to call updateDeliverable and disableDeliverable()');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Prev signed expiration date: ' || trunc(l_prev_signed_expiration_date));
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Current version expiration date: ' || trunc(l_exp_date));
        END IF;
        l_update_event_tbl(1).event_code := G_CONTRACT_EFFECTIVE_EVENT;
        l_update_event_tbl(1).event_date := l_eff_date;
        l_update_event_tbl(2).event_code := G_CONTRACT_EXPIRE_EVENT;
        l_update_event_tbl(2).event_date := l_exp_date;
        -- If last signed version's expiration date is different from the current version's expiration date
        -- we need to call deliverables API for synching previous signed deliverables.
        -- This logic is executed to handle the null date scenarios
        IF (trunc(l_prev_signed_expiration_date)=trunc(l_exp_date)) THEN
           l_expiration_date_matches_flag := FND_API.G_TRUE;
        END IF;

        IF (trunc(l_prev_signed_effective_date)=trunc(l_eff_date)) THEN
           l_effective_date_matches_flag := FND_API.G_TRUE;
        END IF;

        IF ((l_expiration_date_matches_flag = FND_API.G_FALSE ) OR (l_effective_date_matches_flag = FND_API.G_FALSE)) THEN
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables');
             END IF;
             OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables (
                p_api_version                 => 1.0,
                p_init_msg_list               => FND_API.G_FALSE,
                p_commit                    => FND_API.G_FALSE,
                p_bus_doc_id                  => l_contract_id,
                p_bus_doc_type                => l_contract_type,
                p_bus_doc_version             => l_contract_version,
                p_bus_doc_date_events_tbl     => l_update_event_tbl,
                x_msg_data                    => l_msg_data,
                x_msg_count                   => l_msg_count,
                x_return_status               => l_return_status);

             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'OKC_DELIVERABLE_PROCESS_PVT.updateDeliverables return status is : '
                  || l_return_status);
             END IF;
             -----------------------------------------------------
             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
             --------------------------------------------------------
       END IF;  -- expiration date comparision
       -- Disable prev. version deliverables
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables');
       END IF;
       OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables (
                p_api_version                 => 1.0,
                p_init_msg_list               => FND_API.G_FALSE,
                p_commit                    => FND_API.G_FALSE,
                p_bus_doc_id                  => l_contract_id,
                p_bus_doc_type                => l_contract_type,
                p_bus_doc_version             => l_latest_ver,
                x_msg_data                    => l_msg_data,
                x_msg_count                   => l_msg_count,
                x_return_status               => l_return_status);

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'OKC_DELIVERABLE_PROCESS_PVT.disableDeliverables return status is : '
                  || l_return_status);
       END IF;
       END IF;  -- (l_sync_flag = 'Y')

   END IF ; --End Activating Deliverables for ACQ

	   RETURN;
      END IF;  -- (funcmode = 'RUN')

    EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.approve_contract with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'approve_contract',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END approve_contract;

-- Start of comments
--API name      : reject_contract
--Type          : Private.
--Function      : This procedure is called by workflow after the contract is rejected. Updates Contract's status
--                to rejected and logs the status change in OKC_REP_CON_STATUS_HIST table.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE reject_contract(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_contract_version       OKC_REP_CONTRACTS_ALL.contract_version_num%type;
    l_api_name      VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    BEGIN

    l_api_name := 'reject_contract';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.reject_contract');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;
      if (funcmode = 'RUN') then
        l_contract_id := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_ID');
        l_contract_version := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_VERSION');
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Id is: ' || to_char(l_contract_id));
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Version is: ' || to_char(l_contract_version));
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.change_contract_status');
        END IF;

        -- Update the contract status and add a record in OKC_REP_CON_STATUS_HIST table.
        OKC_REP_UTIL_PVT.change_contract_status(
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_contract_id         => l_contract_id,
          p_contract_version    => l_contract_version,
          p_status_code         => G_STATUS_REJECTED,
          p_user_id             => fnd_global.user_id,
          p_note                => NULL,
        x_msg_data            => l_msg_data,
          x_msg_count           => l_msg_count,
          x_return_status       => l_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.change_contract_status with return status: ' || l_return_status);
        END IF;
      -----------------------------------------------------
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      --------------------------------------------------------

        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                g_module || l_api_name,
                'Leaving OKC_REP_WF_PVT.reject_contract');
        END IF;
        RETURN;
      END IF;  -- (funcmode = 'RUN')
    EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.reject_contract with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'reject_contract',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END reject_contract;



-- Start of comments
--API name      : is_contract_approved
--Type          : Private.
--Function      : This procedure is called by workflow to determine if the contract is approved.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
  PROCEDURE is_contract_approved(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid   in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2) IS

    l_api_name            VARCHAR2(30);
    l_contract_id         OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_process_complete_yn varchar2(1);
    l_next_approvers      ame_util.approversTable2;
    l_item_indexes        ame_util.idList;
    l_item_classes        ame_util.stringList;
    l_item_ids            ame_util.stringList;
    l_item_sources        ame_util.longStringList;
    l_user_names            varchar2(4000);

    BEGIN

    l_api_name := 'is_contract_approved';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.is_contract_approved');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
    END IF;
    IF (funcmode = 'RUN') then
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling wf_engine.GetItemAttrNumber to get CONTRACT_ID');
        END IF;
        l_contract_id := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_ID');
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Id is: ' || to_char(l_contract_id));
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling ame_api.getNextApprover to get the approver id');
        END IF;
        ame_api2.getNextApprovers1(
              applicationIdIn => G_APPLICATION_ID,
                    transactionTypeIn => G_TRANSACTION_TYPE,
                    transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                    flagApproversAsNotifiedIn => ame_util.booleanFalse,
                    approvalProcessCompleteYNOut => l_process_complete_yn,
                    nextApproversOut => l_next_approvers,
                    itemIndexesOut => l_item_indexes,
                    itemClassesOut => l_item_classes,
                    itemIdsOut => l_item_ids,
                    itemSourcesOut => l_item_sources);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Number of approvers: ' || to_char(l_next_approvers.count));
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'l_process_complete_yn is is_contract_approved: ' || l_process_complete_yn);
        END IF;
        IF (l_process_complete_yn = ame_util.booleanTrue) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                    'The contract is approved');
            END IF;
            resultout := 'COMPLETE:T';
        ELSE
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                    'The contract is rejected');
            END IF;
            resultout := 'COMPLETE:F';
        END IF;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_contract_approved from funcmode=RUN');
        END IF;
        RETURN;
    END IF;  -- (funcmode = 'RUN')

    IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'Leaving OKC_REP_WF_PVT.is_contract_approved from funcmode=CANCEL');
        END IF;
        RETURN;
    END IF;  -- (funcmode = 'CANCEL')

    IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'Leaving OKC_REP_WF_PVT.is_contract_approved from funcmode=TIMEOUT');
        END IF;
        RETURN;
    END IF; -- (funcmode = 'TIMEOUT')

    EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_contract_approved with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'is_contract_approved',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END is_contract_approved;



-- Start of comments
--API name      : is_contract_approved_detailed
--Type          : Private.
--Function      : This procedure is called by workflow to determine if the contract is approved. Uses
--                the detailed values of ame param approvalProcessCompleteYNOut. Is used in
--                Master approval process.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
  PROCEDURE is_contract_approved_detailed(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid   in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2) IS

    l_api_name            VARCHAR2(30);
    l_contract_id         OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_process_complete_yn varchar2(1);
    l_next_approvers      ame_util.approversTable2;
    l_item_indexes        ame_util.idList;
    l_item_classes        ame_util.stringList;
    l_item_ids            ame_util.stringList;
    l_item_sources        ame_util.longStringList;
    l_user_names            varchar2(4000);

    CURSOR wf_process_csr IS
	   SELECT item_key FROM wf_items
	      WHERE item_type=itemtype
		  AND item_key like itemkey || '_' || '%'
		  and end_date is null;

	wf_process_rec                wf_process_csr%ROWTYPE;

    BEGIN

    l_api_name := 'is_contract_approved_detailed';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.is_contract_approved');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
    END IF;
    IF (funcmode = 'RUN') then
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling wf_engine.GetItemAttrNumber to get CONTRACT_ID');
        END IF;
        l_contract_id := wf_engine.GetItemAttrNumber(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'CONTRACT_ID');
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Contract Id is: ' || to_char(l_contract_id));
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Calling ame_api.getNextApprover to get the approver id');
        END IF;
        -- Using this API to determine if process is complete. Complete process from AME implies
        -- Contract is Approved.
        ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;
        ame_api2.getNextApprovers1(
              applicationIdIn => G_APPLICATION_ID,
                    transactionTypeIn => G_TRANSACTION_TYPE,
                    transactionIdIn => fnd_number.number_to_canonical(l_contract_id),
                    flagApproversAsNotifiedIn => ame_util.booleanFalse,
                    approvalProcessCompleteYNOut => l_process_complete_yn,
                    nextApproversOut => l_next_approvers,
                    itemIndexesOut => l_item_indexes,
                    itemClassesOut => l_item_classes,
                    itemIdsOut => l_item_ids,
                    itemSourcesOut => l_item_sources);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Number of approvers: ' || to_char(l_next_approvers.count));
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'l_process_complete_yn is is_contract_approved_detailed: ' || l_process_complete_yn);
        END IF;
        IF ((l_process_complete_yn = 'Y') OR
		    (l_process_complete_yn = 'X')) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                    'The contract is approved');
            END IF;
            resultout := 'COMPLETE:T';
        ELSE
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
                    'The contract is rejected');
            END IF;
            resultout := 'COMPLETE:F';
        END IF;
        -- We need to loop through the pending notif. process and abort those
        FOR wf_process_rec IN wf_process_csr
          LOOP
          	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module || l_api_name,
                    'Calling WF_ENGINE.AbortProcess');
            END IF;

            WF_ENGINE.AbortProcess(
               itemtype => itemtype,
               itemkey  => wf_process_rec.item_key,
               result    => 'COMPLETE:',
               verify_lock => false,
               cascade   => true);
          END LOOP;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_contract_approved_detailed from funcmode=RUN');
        END IF;
        RETURN;
    END IF;  -- (funcmode = 'RUN')

    IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'Leaving OKC_REP_WF_PVT.is_contract_approved_detailed from funcmode=CANCEL');
        END IF;
        RETURN;
    END IF;  -- (funcmode = 'CANCEL')

    IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_module || l_api_name,
             'Leaving OKC_REP_WF_PVT.is_contract_approved_detailed from funcmode=TIMEOUT');
        END IF;
        RETURN;
    END IF; -- (funcmode = 'TIMEOUT')

    EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.is_contract_approved_detailed with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'is_contract_approved_detailed',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END is_contract_approved_detailed;




-- Start of comments
--API name      : complete_notification
--Type          : Private.
--Function      : This procedure is called by workflow after the approver responds to the Approval Notification Message.
--              : It completes the master process's waiting activity.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments
    PROCEDURE complete_notification(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_contract_version  OKC_REP_CONTRACTS_ALL.contract_version_num%type;
    l_api_name          VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_master_key        wf_items.user_key%TYPE;

    l_wf_note  VARCHAR2(2000);

    BEGIN

    l_api_name := 'complete_notification';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.complete_notification');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;
      if (funcmode = 'RUN') then
        l_master_key := wf_engine.GetItemAttrText(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'MASTER_ITEM_KEY');

          l_wf_note :=     wf_engine.GetItemAttrText(
              itemtype  => itemtype,
              itemkey   => itemkey,
              aname     => 'WF_NOTE');

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                 g_module || l_api_name,
                 'Master Item Key is: ' || l_master_key);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Completing master process waiting activity');
        END IF;

        wf_engine.setItemAttrText(
              itemtype  => itemtype,
              itemkey   => l_master_key,
              aname     => 'WF_NOTE',
              avalue => l_wf_note);


        wf_engine.CompleteActivity(
        	itemtype  => itemtype,
        	itemkey   => l_master_key,
            activity  => 'WAIT_FOR_APPROVER_RESPONSE',
            result    => null);

        resultout := 'COMPLETE:';
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                g_module || l_api_name,
                'Leaving OKC_REP_WF_PVT.complete_notification');
        END IF;
        RETURN;
      END IF;  -- (funcmode = 'RUN')
    EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.complete_notification with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'complete_notification',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;
    END complete_notification;

--Bug 6957819
-- Start of comments
--API name      : con_has_terms
--Type          : Private.
--Function      : This procedure is called by workflow to check if terms has been applied on the document.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments

    PROCEDURE con_has_terms(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_contract_type     OKC_REP_CONTRACTS_ALL.contract_type%TYPE;
    l_api_name          VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_master_key        wf_items.user_key%TYPE;
    l_value VARCHAR2(1);


    BEGIN

    l_api_name := 'con_has_terms';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.complete_notification');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;

       IF (funcmode = 'RUN') THEN
        l_contract_id := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_ID');

        l_contract_type := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_TYPE');

            l_value := OKC_TERMS_UTIL_GRP.HAS_TERMS(   p_document_type => l_contract_type,
                                            p_document_id   => l_contract_id);
          IF (l_value = 'Y') THEN
            resultout := 'COMPLETE:T';
          ELSE
            resultout := 'COMPLETE:F';
          END IF;
        END IF; -- RUN

        EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.con_has_terms with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'con_has_terms',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;

    END con_has_terms;

         -- Start of comments
--API name      : Con_attach_generated_YN
--Type          : Private.
--Function      : This procedure is called by workflow to check if terms has been applied on the document.
--Pre-reqs      : None.
--Parameters    :
--IN            : itemtype         IN VARCHAR2       Required
--                   Workflow item type parameter
--              : itemkey          IN VARCHAR2       Required
--                   Workflow item key parameter
--              : actid            IN VARCHAR2       Required
--                   Workflow actid parameter
--              : funcmode         IN VARCHAR2       Required
--                   Workflow function mode parameter
--OUT           : resultout        OUT  VARCHAR2(1)
--                   Workflow standard out parameter
-- Note         :
-- End of comments

    PROCEDURE con_attach_generated_yn(
        itemtype  IN varchar2,
        itemkey   IN varchar2,
        actid     IN number,
        funcmode  IN varchar2,
        resultout OUT nocopy varchar2
    ) IS

    l_contract_id       OKC_REP_CONTRACTS_ALL.contract_id%type;
    l_contract_type     OKC_REP_CONTRACTS_ALL.contract_type%TYPE;
    l_con_req_id           OKC_CONTRACT_DOCS.request_id%TYPE;
    l_api_name          VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_master_key        wf_items.user_key%TYPE;
    l_value VARCHAR2(1);

    CURSOR contract_attachment_exists(l_contract_id IN NUMBER,l_contract_type IN VARCHAR2, l_con_req_id IN NUMBER) IS
     select 'Y'
      from okc_contract_docs
      where business_document_type = l_contract_type
      and business_document_id = l_contract_id
      AND request_id =  l_con_req_id;

    BEGIN

    l_api_name := 'con_attach_generated_yn';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.complete_notification');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Type is: ' || itemtype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Item Key is: ' || itemkey);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'actid is: ' || to_char(actid));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Function mode is: ' || funcmode);
      END IF;

       IF (funcmode = 'RUN') THEN
        l_contract_id := wf_engine.GetItemAttrNumber(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_ID');

        l_contract_type := wf_engine.GetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'CONTRACT_TYPE');

        l_con_req_id := wf_engine.GetItemAttrNumber(
                itemtype => itemtype,
                itemkey    => itemkey,
                aname => 'CONC_REQUEST_ID' );

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1810: Entering con_attach_generated_yn');
           END IF;

          OPEN contract_attachment_exists(l_contract_id, l_contract_type, l_con_req_id) ;
          FETCH contract_attachment_exists  into  l_value;
          CLOSE contract_attachment_exists ;

          IF (l_value = 'Y') THEN
            resultout := 'COMPLETE:T';
          ELSE
            resultout := 'COMPLETE:F';
          END IF;

        END IF; -- RUN
       EXCEPTION
        WHEN others THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving OKC_REP_WF_PVT.con_attach_generated_yn with exceptions ' || sqlerrm);
          END IF;
          wf_core.context('OKC_REP_WF_PVT',
          'con_attach_generated_yn',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
        raise;

    END con_attach_generated_yn;

END OKC_REP_WF_PVT;

/
