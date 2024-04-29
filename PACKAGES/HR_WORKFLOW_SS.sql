--------------------------------------------------------
--  DDL for Package HR_WORKFLOW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WORKFLOW_SS" AUTHID CURRENT_USER AS
/* $Header: hrwkflss.pkh 120.1.12010000.4 2010/03/14 18:56:21 ckondapi ship $ */
/*
   This package contails new (v4.0+)workflow related business logic
*/
-- ----------------------------------------------------------------------------
-- |-------------------------< branch_on_approval_flag>------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will read the HR_RUNTIME_APPROVAL_REQ_FLAG item level
-- attribute value and branch accordingly. This value will be set by the review
-- page by reading its attribute level attribute HR_APPROVAL_REQ_FLAG
-- (YES/NO/YES_DYNAMIC)
-- For
--  YES          => branch with Yes result
--  YES_DYNAMIC  => branch with Yes result
--  NO           => branch with No result
-- ----------------------------------------------------------------------------
--
PROCEDURE branch_on_approval_flag
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2);


-- ----------------------------------------------------------------------------
-- |----------------------< set_rejected_by_payroll > -------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will set the item attribute HR_REJECTED_BY_PAYROLL
-- to 'Y'.
-- ----------------------------------------------------------------------------
PROCEDURE set_rejected_by_payroll
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2);


-- ----------------------------------------------------------------------------
-- |----------------------- < copy_payroll_comment > -------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will populate the wf_note from WF and set the item
--          attribute HR_SALBASISCHG_PAYROLL_COMMENT with that value.
-- ----------------------------------------------------------------------------
PROCEDURE copy_payroll_comment
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2);

function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
function get_process_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
function get_approval_level
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;
function get_effective_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return date;
function get_assignment_id
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;
function get_final_approver
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
-- This procedure confirms to the Workflow API specification standards.
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );


--
-- ------------------------------------------------------------------------
-- |------------------------< update_approval_status >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Update the status of the current approvers' approval notification
-- This procedure confirms to the Workflow API specification standards.
--
--
procedure update_approval_status (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );


function allow_requestor_approval
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
--
-- ------------------------------------------------------------------------
-- |------------------ < check_mid_pay_period_change > --------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if a mid pay period change was performed when a salary basis
--  was changed.  If yes, we need to set the WF item attribute
--  HR_MID_PAY_PERIOD_CHANGE ='Y' so that a notification will be sent to the
--  Payroll Contact.
--
--  This procedure is invoked by the WF HR_CHK_SAL_BASIS_MID_PAY_PERIOD process.
-- ------------------------------------------------------------------------
--
procedure check_mid_pay_period_change
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_act_id       in number,
              funmode        in varchar2,
              result         out nocopy varchar2 );


--
-- ------------------------------------------------------------------------
-- |------------------ < APPS_INITIALIZE > --------------------|
--  Method to initialize the session apps context if there is no context already
--  set.
-- ------------------------------------------------------------------------

PROCEDURE  apps_initialize
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);


--
-- ------------------------------------------------------------------------
-- |------------------ < DEFER_COMMIT > --------------------|
--  Method to read profile value (HR_DEFER_UPDATE)
--  and branch the workflow accordingly.
-- ------------------------------------------------------------------------
procedure defer_commit
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_act_id       in number,
              funmode        in varchar2,
              result          in out  nocopy varchar2 ) ;
--


--
-- |------------------ <GetActivityAttrText > --------------------|
--   Get the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in varchar2 default 'FALSE')
return varchar2;

--
-- |------------------ <GetActivityAttrNumber > --------------------|
--   Get the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrNumber(itemtype in varchar2,
                               itemkey in varchar2,
                               actid in number,
                               aname in varchar2,
                               ignore_notfound in varchar2 default 'FALSE')
return number;

--
-- |------------------ <GetActivityAttrDate > --------------------|
--   Get the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in varchar2 default 'FALSE')
return date;


procedure getPageDetails
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_activityId   out nocopy  number,
              p_page         out nocopy  varchar2,
              p_page_type    out nocopy  varchar2,
              p_page_applicationId out nocopy  varchar2,
              p_additional_params out nocopy  varchar2 ) ;

function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2,
                         ignore_notfound in varchar2 default 'FALSE')
return varchar2;

procedure get_item_type_and_key (
              p_ntfId       IN NUMBER
             ,p_itemType   OUT NOCOPY VARCHAR2
             ,p_itemKey    OUT NOCOPY VARCHAR2 );

procedure build_edit_link(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) ;

function GetAttrText (nid in number,
                      aname in varchar2,
		      ignore_notfound in varchar2 default 'FALSE') return varchar2;

function getApprStartingPointPersonId
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE) return number;


procedure updateSFLTransaction (itemtype    in varchar2,
                                itemkey     in varchar2,
			        actid       in number,
		                funmode     in varchar2,
				result      out nocopy varchar2     );


procedure getProcessDisplayName(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) ;

function getProcessDisplayName(itemtype    in varchar2,
                               itemkey     in varchar2)
			       return wf_runnable_processes_v.display_name%type;



procedure getApprovalMsgSubject(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) ;
function getNextApproverForHist(p_item_type    in varchar2,
                                p_item_key     in varchar2) return varchar2;

function Authenticate(
  p_username in varchar2,
  p_nid in number,
  p_nkey in varchar2)
return varchar2;

function Authenticate(p_username in varchar2,
                      p_txn_id     in number
                      )
return varchar2;

function getOrganizationManagersubject
         (p_item_type IN varchar2,
         p_item_key IN varchar2)
return varchar2;

PROCEDURE isFyiNtfDet
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2);

END hr_workflow_ss;

/
