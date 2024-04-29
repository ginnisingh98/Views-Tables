--------------------------------------------------------
--  DDL for Package OKC_REP_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPWFS.pls 120.2.12010000.2 2013/06/04 11:14:24 aksgoyal ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
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

   ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
   -- Required for Contract not found error message
  G_INVALID_CONTRACT_ID_MSG    CONSTANT   VARCHAR2(200) := 'OKC_REP_INVALID_CONTRACT_ID';
  G_CONTRACT_ID_TOKEN          CONSTANT   VARCHAR2(200) := 'CONTRACT_ID';

  -- Contracts business events codes TBL Type
  SUBTYPE EVENT_TBL_TYPE IS OKC_MANAGE_DELIVERABLES_GRP.BUSDOCDATES_TBL_TYPE;

   -- Contract events - deliverables integration
  G_CONTRACT_EXPIRE_EVENT     CONSTANT   VARCHAR2(200) := 'CONTRACT_EXPIRE';
  G_CONTRACT_EFFECTIVE_EVENT     CONSTANT   VARCHAR2(200) := 'CONTRACT_EFFECTIVE';

  PROCEDURE initialize_attributes(
      itemtype  in varchar2,
      itemkey   in varchar2,
      actid   in number,
      funcmode  in varchar2,
      resultout out nocopy varchar2
    );

-- Start of comments
--API name      : has_next_approver
--Type          : Private.
--Function      : This procedure is called by workflow to get the next approver in the list.
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
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid   in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
    );

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
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
    );


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
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
    );

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
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
    );


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
    resultout out nocopy varchar2
    );



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
    );





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
    );



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
    resultout out nocopy varchar2
	);



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
    );

--bug 6957819
-- Start of comments
--API name      : Con_Has_Terms
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
    );

             -- Start of comments
--API name      : con_attach_generated_YN
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
    );

END OKC_REP_WF_PVT;

/
