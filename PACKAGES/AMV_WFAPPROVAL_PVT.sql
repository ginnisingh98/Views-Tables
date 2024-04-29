--------------------------------------------------------
--  DDL for Package AMV_WFAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_WFAPPROVAL_PVT" AUTHID CURRENT_USER as
/* $Header: amvvwfas.pls 120.1 2005/06/30 13:37:09 appldev ship $ */

--
-- Procedure
--	StartProcess
--
-- Description
--      Initiate workflow for a requisition
-- IN
--   RequestorId	- PK of requestor, Item owner or Subscriber
--   RequestorName	- Name of Item owner or Subscriber
--   ItemId		- Id of Item published
--   ItemName		- Item document
--   ChannelId  	- PK of Channek
--   ChannelName  	- Name Channel of the channel
--   ProcessOwner 	- Requisition Process Owner Username from calling appl
--   Workflowprocess    - Workflow process to run.
--
PROCEDURE StartProcess(	RequestorId		in number,
			ItemId			in number default null,
			ChannelId		in number,
                        Timeout                 in number default null,
			ProcessOwner		in varchar2,
			Workflowprocess		in varchar2,
                        Item_Type               in varchar2 default null);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Is_ChannelApprover
--
-- Description
--	 Check if the User is an approver for the channel
-- IN
--	channel_id
--	user_id
--
-- Returns
--    TRUE  -  If User has privilege to approve channel
--    FALSE -  If User does not have the privilege to approve channel
--
FUNCTION Is_ChannelApprover ( 	channel_id in number,
				user_id in number ) return boolean;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Can_Publish
--
--   Workflow cover: Check if the user can publish a document in the channel
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:Y' IF user can subscribe without approval
--		  - 'COMPLETE:N' IF user cannot subscribe without approval
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 	<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_CAN_SUBSCRIBE
--
--
PROCEDURE Can_Publish ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	OUT NOCOPY varchar2	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Can_Subscribe
--
--   Workflow cover: Check if user can subscribe to a channel without approval
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:Y' IF user can subscribe without approval
--		  - 'COMPLETE:N' IF user cannot subscribe without approval
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 	<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_CAN_SUBSCRIBE
--
--
PROCEDURE Can_Subscribe ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	OUT NOCOPY varchar2	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	GetApprover
--
-- Description
--	Select an Approver
-- IN
--	channel
--	approver type
-- Out
--      approver
--
PROCEDURE GetApprover (channel_id 	in number,
		       approver_in_type in varchar2,
		       approver_out_type OUT NOCOPY varchar2,
		       approvers 	OUT NOCOPY varchar2 );
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--
-- Select_Approver
--
--
-- Select_Approver
--   Workflow cover: Select a channel approver and set Workflow item attributes
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:T' IF channel has approver
--		  - 'COMPLETE:F' IF channel does not any more approver
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 	<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_SELECT_APPROVER
--
PROCEDURE Select_Approver ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	OUT NOCOPY varchar2	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Notification_Results
--
--
-- Notification_Results
--   Workflow cover: End the notification process based on the result
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMV_APPROVAL_PVT    AMV_NTF_APPROVAL
--
PROCEDURE Notification_Results (itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Approve_Item
--
-- Description - Approve an item for channel
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   itemuserkey - A string generated from the application object user-friendly
--               primary key.
--   actid     - The function activity(instance id).
--   processowner - The username owner for this item instance.
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   resultout    - Name of workflow process to run
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 	<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_APPROVE_ITEM
--
PROCEDURE Approve_Item (	itemtype	in varchar2,
			itemkey  	in varchar2,
			actid		in number,
			funcmode	in varchar2,
			resultout	OUT NOCOPY varchar2	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Approve_Subscription
--
-- Description -  Subscribe a user to a channel
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
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 	<ACTIVITY>
--   AMV_APPROVAL_PVT   AMV_APPROVE_SUBSCRIPTON
--
PROCEDURE Approve_Subscription (itemtype	in varchar2,
			itemkey  	in varchar2,
			actid		in number,
			funcmode	in varchar2,
			resultout	OUT NOCOPY varchar2	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Reject_Item
--
-- Description - Reject an item for a channel
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
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 	<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_REJECT_ITEM
--
PROCEDURE Reject_Item (	itemtype	in varchar2,
			itemkey  	in varchar2,
			actid		in number,
			funcmode	in varchar2,
			resultout	OUT NOCOPY varchar2	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END amv_wfapproval_pvt;

 

/
