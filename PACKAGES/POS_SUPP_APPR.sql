--------------------------------------------------------
--  DDL for Package POS_SUPP_APPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPP_APPR" AUTHID CURRENT_USER as
/* $Header: POSSPAPS.pls 120.3.12010000.19 2014/07/14 06:46:30 spapana ship $ */

ameApplicationId     number :=177; /* ame is using POS id  */
ameTransactionType   varchar2(50) := 'POS_SUPP_APPR';  /* Transaction type used by ame */
wfItemType  varchar2(50) := 'POSSPAPP'; /* Workflow Item Type */
wfProcess varchar2(50) := 'POSSPAPP_PROCESS';  /* Workflow process name */
g_next_approvers ame_util.approversTable2;

fieldDelimiter    constant varchar2(1) := ',';
quoteChar         constant varchar2(1) := '\';

yesChar VARCHAR2(1) := 'Y';
noChar  VARCHAR2(1) := 'N';
ameApprovedStatus VARCHAR2(15) := 'APPROVED';
ameRejectedStatus VARCHAR2(15) := 'REJECTED';
ameInprocessStatus VARCHAR2(15) := 'INPROCESS';
ameReturnStatus   VARCHAR2(15) := 'RETURN';
ameReturnToSupplierStatus   VARCHAR2(20) := 'RETURNTOSUPPLIER';
amePublishRFI   VARCHAR2(20) := 'PUBLISHRFI';
g_userAction VARCHAR2(50);
noAme VARCHAR2(10) := 'NOAME';
g_isAnyError VARCHAR2(10) := 'N';

PROCEDURE INITIALIZE_WF(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT nocopy VARCHAR2);

PROCEDURE IS_AME_ENABLED(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT nocopy VARCHAR2);

PROCEDURE GET_NEXT_APPROVER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT nocopy VARCHAR2);

PROCEDURE STARTWF_POSSPAPP(
    suppid        IN VARCHAR2,
    suppname      IN VARCHAR2,
    requestor     IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2);

PROCEDURE CHECK_IF_AME_ENABLED(
    result IN OUT nocopy VARCHAR2);

PROCEDURE GET_APPROVER_IN_WF(
    suppid IN VARCHAR2,
    user_id OUT nocopy        VARCHAR2,
    user_name OUT nocopy      VARCHAR2,
    user_firstname OUT nocopy VARCHAR2,
    user_lastname OUT nocopy  VARCHAR2,
    status IN OUT nocopy      VARCHAR2);

PROCEDURE CHECK_IF_APPROVER(
    suppid   IN VARCHAR2,
    approver IN VARCHAR2,
    result   IN OUT nocopy VARCHAR2);

PROCEDURE PROCESS_SUPP_REG(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_RETURN_WF_WRAPPER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_FORWARD_WF_WRAPPER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_APPR_FWD_WF_WRAPPER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_APPROVE_WF_WRAPPER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_APPROVE(
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2);

PROCEDURE PROCESS_REJECT_WF_WRAPPER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_REJECT(
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2 );

PROCEDURE PROCESS_FORWARD(
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2 );

PROCEDURE PROCESS_APPROVE_FORWARD(
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2);

PROCEDURE GET_AME_PROCESS_STATUS(
    suppid IN VARCHAR2,
    result  IN OUT nocopy VARCHAR2);

PROCEDURE get_ame_approval_list_history(
    pProspSupplierId IN VARCHAR2,
    pApprovalListStr OUT NOCOPY   VARCHAR2,
    pApprovalListCount OUT NOCOPY NUMBER,
    pQuoteChar OUT NOCOPY         VARCHAR2,
    pFieldDelimiter OUT NOCOPY    VARCHAR2);

PROCEDURE Process_Response_Internal(
    itemkey    IN VARCHAR2,
    p_response IN VARCHAR2 );

PROCEDURE ACK_SUPP_REG(
    suppid        IN VARCHAR2,
    approver      IN VARCHAR2,
    action        IN VARCHAR2,
    comments      IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT NOCOPY VARCHAR2 ) ;

PROCEDURE abort_workflow_process(
    p_itemkey IN VARCHAR2,
    approver  IN VARCHAR2,
    group_id VARCHAR2,
    action IN VARCHAR2,
    result IN OUT NOCOPY VARCHAR2 );

PROCEDURE get_approver_record(
    p_itemKey         IN VARCHAR2,
    approver          IN VARCHAR2,
    group_or_chain_id IN VARCHAR2,
    approverRecord    IN OUT NOCOPY ame_util.approverRecord2);

PROCEDURE PROCESS_RETURN(
    itemkey       IN VARCHAR2,
    result        IN OUT NOCOPY VARCHAR2,
    processresult IN OUT NOCOPY VARCHAR2);

PROCEDURE Launch_Parallel_Approval(
    itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

PROCEDURE POST_APPROVAL_NOTIF(
    itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

PROCEDURE get_wf_details
  (
    p_itemkey         IN VARCHAR2,
    approver          IN VARCHAR2,
    approverWFItemKey IN OUT nocopy VARCHAR2,
    notificationID    IN OUT NOCOPY VARCHAR2,
    wf_process_status IN OUT NOCOPY VARCHAR2
  );

FUNCTION CHECK_CURRENT_APPROVER(
      suppid IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION GET_APPROVER_NAME_IN_WF(
      suppid IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION GET_WF_TOP_PROCESS_ITEM_KEY(
      suppid IN VARCHAR2)
    RETURN VARCHAR2;

PROCEDURE get_current_approver_details(
      itemkey           IN VARCHAR2,
      approver          IN VARCHAR2,
      isCurrentApprover IN OUT NOCOPY VARCHAR2,
      approverName      IN OUT NOCOPY VARCHAR2 );

PROCEDURE get_all_approvers(
      suppid       IN VARCHAR2,
      l_approver_list IN OUT NOCOPY ame_util.approversTable2,
      l_process_out   IN OUT NOCOPY VARCHAR2);

PROCEDURE CHECK_IF_RESUBMIT(
      itemtype IN VARCHAR2,
      itemkey  IN VARCHAR2,
      actid    IN NUMBER,
      funcmode IN VARCHAR2,
      resultout OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_MANDATORY_ATTR(
      itemtype IN VARCHAR2,
      itemkey  IN VARCHAR2,
      actid    IN NUMBER,
      funcmode IN VARCHAR2,
      resultout OUT NOCOPY VARCHAR2);

PROCEDURE GET_ERROR_DOC
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

PROCEDURE VALIDATE_DATA(
    p_suppid IN VARCHAR2,
    p_error_mesg IN OUT NOCOPY VARCHAR2);

PROCEDURE GET_REG_REQ_EDIT_URL
  (
    p_regId  IN VARCHAR2,
    p_url IN OUT NOCOPY VARCHAR2
  );

FUNCTION GET_BUYER_ACTN_NOTIF_SUBJECT(p_supp_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_BUYER_FYI_NOTIF_SUBJECT(p_supp_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_BUYER_ERR_NOTIF_SUBJECT(p_supp_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE IS_REOPENED_REQUEST
(
suppid IN VARCHAR2,
result IN OUT NOCOPY VARCHAR2
);
PROCEDURE RESUBMIT_FOR_REJECT_OR_RETURN
(
suppid IN VARCHAR2,
action_code IN OUT NOCOPY VARCHAR2
);
PROCEDURE send_fyi_notification
(
  ameTrxId  IN VARCHAR2
);
PROCEDURE getNextApprIdBasedOnApprType
(
 p_origSystem IN VARCHAR2,
 p_origSystemId IN NUMBER,
 p_nextApproveId OUT NOCOPY NUMBER,
 l_next_approver_name OUT NOCOPY per_employees_current_x.full_name%TYPE
);
PROCEDURE send_notif_to_new_approver
(
  p_suppId IN VARCHAR2
);
PROCEDURE get_current_appr_group_details
(
  p_suppId IN VARCHAR2,
  p_groupIds OUT NOCOPY Dbms_Sql.Number_Table,
  p_orderIds OUT NOCOPY Dbms_Sql.Number_Table
);
PROCEDURE POS_SUPP_REG_WF_SELECTOR
(
    p_itemtype IN VARCHAR2,
    p_itemkey  IN VARCHAR2,
    p_actid    IN NUMBER,
    p_funcmode IN VARCHAR2,
    p_x_result IN OUT NOCOPY VARCHAR2
);
PROCEDURE GET_RESP_ID
(
    p_userid IN VARCHAR2,
    p_funcname  IN VARCHAR2,
    p_applid IN NUMBER,
    p_respid IN OUT NOCOPY NUMBER,
    p_respkey IN OUT NOCOPY VARCHAR2,
    p_x_result IN OUT NOCOPY VARCHAR2
);
end POS_SUPP_APPR;

/
