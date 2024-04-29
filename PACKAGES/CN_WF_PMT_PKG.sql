--------------------------------------------------------
--  DDL for Package CN_WF_PMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_WF_PMT_PKG" AUTHID CURRENT_USER as
-- $Header: cnwfpmts.pls 115.6 2002/11/21 21:20:25 hlchen ship $ --+
--
-- Procedure
--	StartProcess
--
-- Description		starts the workflow.
--
-- IN
--   srp_role_id
--   RequestorUsername  - Requisition Requestor Username from callling application
--   ProcessOwner	- Requisition process Owner Username from calling application
--   Workflowprocess    - Workflow process to run.
--
procedure StartProcess(	p_posting_detail_id	in number,
			p_RequestorUsername	in varchar2,
			p_ProcessOwner		in varchar2,
			p_WorkflowProcess	in varchar2,
			p_Item_Type		in varchar2 );
-- Procedure
--	Get_ccid
--
-- Description		gets the ccid
--
-- IN
--   itemkey
--   RequestorUsername  - Requisition Requestor Username from callling application
--   ProcessOwner	- Requisition process Owner Username from calling application
--   Workflowprocess    - Workflow process to run.
--
procedure get_ccid(  	itemtype	in varchar2,
	itemkey  	in varchar2,
	actid		in number,
	funcmode	in varchar2,
	resultout out nocopy varchar2	) ;

--
-- Procedure
--	selector
--
-- Description
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   itemuserkey - A string generated from the application object user-friendly
--               primary key.
--   actid     - The function activity(instance id).
--   processowner - The username owner for this item instance.
--   funcmode  - Run/Cancel
-- OUT
--   resultout    - Name of workflow process to run
--
procedure Selector (	itemtype	in varchar2,
			itemkey  	in varchar2,
			actid		in number,
			funcmode	in varchar2,
			resultout out nocopy varchar2	);

-- Record_Notification
--   Records the notification
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - 'COMPLETE'
--

procedure update_trx_ccid (	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	);

-- Procedure
--	Get_acc_gen_type
--
-- Description		dummy procedure
--
-- IN
--   itemkey
--
procedure get_acc_gen_type
  (  	itemtype	in varchar2,
	itemkey  	in varchar2,
	actid		in number,
	funcmode	in varchar2,
	resultout out nocopy varchar2	);

end CN_WF_PMT_PKG;

 

/
