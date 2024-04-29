--------------------------------------------------------
--  DDL for Package Body AMV_WFAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_WFAPPROVAL_PVT" as
/* $Header: amvvwfab.pls 120.1 2005/06/21 16:54:58 appldev ship $ */

--
-- Procedure
--	StartProcess
--
-- Description
--      Initiate workflow for a requisition
-- IN
--   RequestorId	- PK of requestor, Item owner or Subscriber
--   ItemId		- PK of Item published
--   ChannelId  	- PK of Channek
--   ProcessOwner 	- Requisition Process Owner Username from calling appl
--   Workflowprocess - Workflow process to run.
--
PROCEDURE StartProcess(	RequestorId		in number,
					ItemId			in number default null,
					ChannelId			in number,
					Timeout			in number default null,
					ProcessOwner		in varchar2,
					WorkflowProcess	in varchar2,
					Item_Type			in varchar2 default null) IS
--
--
ItemType	varchar2(30) := nvl(Item_Type, 'AMV_APPR');
ItemKey	varchar2(30);
ItemUserKey	varchar2(80);

l_item_key		number;
l_channel_name		varchar2(80);
l_requestor		varchar2(80);
l_item_name		varchar2(240);
--
CURSOR 	Channel_Name IS
select 	channel_name
from		amv_c_channels_vl
where	channel_id = ChannelId;

CURSOR 	Item_Name IS
select 	item_name
from		jtf_amv_items_vl
where	item_id = ItemId;

CURSOR Requestor_Name IS
select FND.USER_NAME
from   JTF_RS_RESOURCE_EXTNS RD
,      FND_USER FND
where RD.USER_ID = FND.USER_ID
and   RD.RESOURCE_ID = RequestorId;

CURSOR ItemKey_csr IS
select amv_wf_requests_s.nextval
from dual;

BEGIN
   OPEN Channel_Name;
   	FETCH Channel_Name INTO l_channel_name;
   CLOSE Channel_Name;

   OPEN Requestor_Name;
   	FETCH Requestor_Name INTO l_requestor;
   CLOSE Requestor_Name;

   --
   -- keyid for Item key
   OPEN ItemKey_csr;
   	FETCH ItemKey_csr INTO l_item_key;
   CLOSE ItemKey_csr;

  IF WorkflowProcess = AMV_UTILITY_PVT.G_PUB_APPROVAL THEN
   --
   OPEN Item_Name;
    FETCH Item_Name INTO l_item_name;
   CLOSE Item_Name;

   ItemKey := 'PUB'||l_item_key;
   ItemUserKey := substr(l_channel_name,1,19)||'_'||substr(l_item_name,1,60);
   --
  ELSE
   --
   ItemKey := 'SUB'||l_item_key;
   ItemUserKey:=substr(l_channel_name,1,59)||'_'||RequestorId;
   --
  END IF;

  --
  -- Start Process :
  --
  wf_engine.CreateProcess( 	ItemType => ItemType,
  		 				ItemKey  => ItemKey,
						process  => WorkflowProcess );

  wf_engine.SetItemUserKey ( 	ItemType	=> ItemType,
						ItemKey	=> ItemKey,
						UserKey	=> ItemUserKey);
  --
  -- Initialize workflow item attributes
  --
  wf_engine.SetItemAttrNumber (itemtype => itemtype,
      					itemkey  	=> itemkey,
 	      				aname 	=> 'AMV_CHANNEL_ID',
						avalue 	=>  ChannelId);
  --
  wf_engine.SetItemAttrText ( itemtype 	=> itemtype,
      					itemkey  	=> itemkey,
 	      				aname  	=> 'AMV_CHANNEL_NAME',
						avalue	=>  l_channel_name);
  --
  wf_engine.SetItemAttrNumber (itemtype => itemtype,
      					itemkey  	=> itemkey,
 	      				aname 	=> 'AMV_REQUESTOR_ID',
						avalue	=>  RequestorId);
  --
  wf_engine.SetItemAttrText (	itemtype 	=> itemtype,
      					itemkey  	=> itemkey,
 	      				aname 	=> 'AMV_REQUESTOR',
						avalue	=>  l_requestor);
  --
  wf_engine.SetItemAttrNumber (itemtype	=> itemtype,
      					itemkey 	=> itemkey,
      					aname  	=> 'AMV_ITEM_ID',
						avalue 	=>  ItemId);
  --
  wf_engine.SetItemAttrText ( itemtype 	=> itemtype,
      					itemkey  	=> itemkey,
      					aname  	=> 'AMV_ITEM_NAME',
						avalue 	=>  l_item_name);
  --
  wf_engine.SetItemAttrNumber (itemtype => itemtype,
      					itemkey  	=> itemkey,
      					aname 	=> 'AMV_TIMEOUT',
						avalue	=>  Timeout);
  --
  wf_engine.SetItemAttrText (	itemtype 	=> itemtype,
      					itemkey  	=> itemkey,
      					aname 	=> 'AMV_WORKFLOW_PROCESS',
						avalue	=>  WorkflowProcess);

  --
  wf_engine.SetItemOwner (	itemtype 	=> itemtype,
						itemkey 	=> itemkey,
						owner 	=> ProcessOwner );

  --
  wf_engine.StartProcess( 	itemtype 	=> itemtype,
      					itemkey	=> itemkey );
  --
EXCEPTION
  WHEN OTHERS THEN
  --
  wf_core.context(	'AMV_WFAPPROVAL_PVT',
				'StartProcess',
				itemtype, itemkey,to_char(ChannelId),Workflowprocess);
  RAISE;
  --
END StartProcess;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Is_ChannelApprover
--
-- Description
--	Check if the User is an approver for the channel
-- IN
--	channel_id
--	user_id
--
-- Returns
--    TRUE  -  If User has privilege to approve channel
--    FALSE -  If User does not have the privilege to approve channel
--
FUNCTION Is_ChannelApprover (	channel_id in number,
						user_id in number ) return boolean IS
--
l_api_version		number := 1.0;
l_return_status	varchar2(1);
l_msg_count		number;
l_msg_data		varchar2(80);
l_setup_result		varchar2(1) := FND_API.G_FALSE;
--
l_default_approver_id 	number;
l_owner_id 		number;
l_create_flag 		varchar2(1);
l_approver_flag 	varchar2(1);
--
CURSOR 	Chan_Approvers IS
select	default_approver_user_id
,		owner_user_id
from		amv_c_channels_b
where	channel_id = channel_id;

CURSOR 	Sec_Approvers IS
select	chl_approver_flag
from		amv_u_access
where	access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and		access_to_table_record_id = channel_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		user_or_group_id = user_id;

BEGIN
  --
  AMV_USER_PVT.Can_ApproveContent(
	p_api_version	=> l_api_version,
	x_return_status => l_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data,
	p_check_login_user	=> FND_API.G_FALSE,
	p_resource_id	=> user_id,
	p_include_group_flag => FND_API.G_TRUE,
	x_result_flag => l_setup_result
  );

  IF l_setup_result = FND_API.G_TRUE THEN
	return(TRUE);
  ELSE
  	OPEN Chan_Approvers;
   		FETCH Chan_Approvers INTO l_default_approver_id, l_owner_id;
 	CLOSE Chan_Approvers;

  	IF l_default_approver_id = user_id THEN
		return(TRUE);
 	ELSIF l_owner_id = user_id THEN
		return(TRUE);
  	ELSE
		OPEN Sec_Approvers;
	  		FETCH Sec_Approvers INTO l_approver_flag;
		CLOSE Sec_Approvers;

		IF l_approver_flag = FND_API.G_TRUE THEN
			return(TRUE);
		ELSE
			return(FALSE);
		END IF;
  	END IF;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
				 'Is_ChannelApprover',
				 channel_id,user_id);
	RAISE;
END Is_ChannelApprover;
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
--   Resultout - 'COMPLETE:Y' IF user can subscribe without approval
--		  	- 'COMPLETE:N' IF user cannot subscribe without approval
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE> 		<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_CAN_PUBLISH
--
--
PROCEDURE Can_Publish ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid	in number,
					funcmode	in varchar2,
					resultout	OUT NOCOPY  varchar2	) IS
--
l_api_version		number := 1.0;
l_return_status	varchar2(1);
l_msg_count		number;
l_msg_data		varchar2(80);
l_setup_result		varchar2(1);
--
l_channel_id		number;
l_requestor_id		number;
l_create_flag 		varchar2(1);
l_publish_flag 	varchar2(1);
--
CURSOR 	Chn_Access IS
select	can_create_flag
from		amv_u_access
where	access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and		access_to_table_record_id = l_channel_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		user_or_group_id = l_requestor_id;

CURSOR  	Chn_Publish IS
select  	pub_need_approval_flag
from		amv_c_channels_b
where	channel_id = l_channel_id;

BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
   	l_channel_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_CHANNEL_ID' );

 	l_requestor_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_REQUESTOR_ID' );

 	--
	AMV_USER_PVT.Can_PublishContent(
		p_api_version	=> l_api_version,
		x_return_status => l_return_status,
		x_msg_count	=> l_msg_count,
		x_msg_data	=> l_msg_data,
		p_check_login_user	=> FND_API.G_FALSE,
		p_resource_id	=> l_requestor_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
 	 );

 	IF l_setup_result = FND_API.G_TRUE THEN
		resultout := wf_engine.eng_completed||':Y';
	ELSE
 		OPEN Chn_Publish;
   			FETCH Chn_Publish INTO l_publish_flag;
 		CLOSE Chn_Publish;

 		IF l_publish_flag = FND_API.G_TRUE THEN
 			IF Is_ChannelApprover(l_channel_id, l_requestor_id) THEN
				resultout := wf_engine.eng_completed||':Y';
 			ELSE
				OPEN Chn_Access;
		  			FETCH Chn_Access INTO l_create_flag;
				CLOSE Chn_Access;

				IF l_create_flag = FND_API.G_TRUE THEN
					resultout := wf_engine.eng_completed||':Y';
				ELSE
					resultout := wf_engine.eng_completed||':N';
				END IF;
			END IF;
 		ELSE
			resultout := wf_engine.eng_completed||':Y';
 		END IF;
	END IF;
 	--

 	--
    	return;
 	--
  END IF;
  --

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
	--
	-- Return process to run
	--
    	resultout := 'COMPLETE:';
    	return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Can_Publish',
			itemtype, itemkey,to_char(actid),funcmode);
	RAISE;
END Can_Publish;
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
PROCEDURE Can_Subscribe (itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					resultout	OUT NOCOPY  varchar2	) IS
--
l_channel_id		number;
l_requestor_id		number;
l_view_flag 		varchar2(1);
l_subscribe_flag 	varchar2(1);
--
CURSOR 	Chn_Access IS
select	can_view_flag
from		amv_u_access
where	access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and		access_to_table_record_id = l_channel_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		user_or_group_id = l_requestor_id;

CURSOR  	Chn_Subscribe IS
select  	sub_need_approval_flag
from		amv_c_channels_b
where	channel_id = l_channel_id;

BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
   	l_channel_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_CHANNEL_ID' );

 	l_requestor_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_REQUESTOR_ID' );

 	OPEN Chn_Subscribe;
  		FETCH Chn_Subscribe INTO l_subscribe_flag;
 	CLOSE Chn_Subscribe;

 	IF l_subscribe_flag = FND_API.G_TRUE THEN
 		IF Is_ChannelApprover(l_channel_id, l_requestor_id) THEN
			resultout := wf_engine.eng_completed||':Y';
 		ELSE
			OPEN Chn_Access;
	  	   		FETCH Chn_Access INTO l_view_flag;
			CLOSE Chn_Access;

			IF l_view_flag = FND_API.G_TRUE THEN
				resultout := wf_engine.eng_completed||':Y';
			ELSE
				resultout := wf_engine.eng_completed||':N';
			END IF;
 		END IF;
	ELSE
			resultout := wf_engine.eng_completed||':Y';
  	END IF;
  	--

	--
    	return;
 	--
  END IF;
  --

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
	--
	-- Return process to run
	--
    	resultout := 'COMPLETE:';
    	return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Can_Subscribe',
			itemtype, itemkey,to_char(actid),funcmode);
	RAISE;
END Can_Subscribe;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	GetApprover
--
-- Description
--	Select an Approver
-- IN
--	channel_id
--	approver_type
--	approver_out
-- Out
--      approver
--
PROCEDURE GetApprover (	channel_id 		in number,
		       	   	approver_in_type 	in varchar2,
		       		approver_out_type 	OUT NOCOPY  varchar2,
		       		approvers 		OUT NOCOPY  varchar2 ) IS
--
l_default_approver 	varchar2(100);
l_channel_owner 	varchar2(100);
l_secn_approver	varchar2(100);
l_record_counter	number;
--
-- NOTE Remove PPX relation in the cursor
CURSOR  Chan_Approvers(chn_id NUMBER) IS
select FND1.USER_NAME
from JTF_RS_RESOURCE_EXTNS RD
,    FND_USER FND1
,       AMV_C_CHANNELS_B CHN
where RD.USER_ID = FND1.USER_ID
and   RD.RESOURCE_ID = CHN.DEFAULT_APPROVER_USER_ID
and   CHN.CHANNEL_ID = chn_id;

CURSOR 	Secn_Approvers IS
select  	fu.user_name
from		amv_u_access acc
,		fnd_user fu
where	acc.access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and		acc.access_to_table_record_id = GetApprover.channel_id
and		acc.user_or_group_type = AMV_UTILITY_PVT.G_USER
and		acc.user_or_group_id = fu.user_id;
--
BEGIN
  OPEN Chan_Approvers(channel_id);
  	FETCH Chan_Approvers INTO l_default_approver;
  CLOSE Chan_Approvers;

  IF approver_in_type = AMV_UTILITY_PVT.G_DEFAULT  THEN
  	approvers := l_default_approver;
	approver_out_type := AMV_UTILITY_PVT.G_DEFAULT;
  ELSIF approver_in_type = AMV_UTILITY_PVT.G_OWNER THEN
	approvers := l_channel_owner;
	approver_out_type := AMV_UTILITY_PVT.G_OWNER;
  ELSIF approver_in_type = AMV_UTILITY_PVT.G_SECONDARY THEN
   	OPEN Secn_Approvers;
    	 LOOP
	  FETCH Secn_Approvers INTO l_secn_approver;
  	  EXIT WHEN Secn_Approvers%NOTFOUND;
		l_record_counter := l_record_counter + 1;
   		approvers := approvers||' '||l_secn_approver;
		approver_out_type := AMV_UTILITY_PVT.G_SECONDARY;
    	 END LOOP;
   	CLOSE Secn_Approvers;

   	IF (l_record_counter is null) THEN
		approvers := l_channel_owner;
		approver_out_type := AMV_UTILITY_PVT.G_OWNER;
   	END IF;
  ELSE
	approver_out_type := AMV_UTILITY_PVT.G_DONE;
  END IF;

EXCEPTION
 WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT','GetApprover',channel_id);
	RAISE;
END GetApprover;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
				resultout	OUT NOCOPY  varchar2	) IS
--
l_channel_id		number;
l_requestor_id		number;
l_item_id		number;
l_channel_name		varchar2(80);
l_item_name		varchar2(240);
l_comments		varchar2(4000);
l_forward_to_username	varchar2(4000);
l_forward_to_usertype	varchar2(30);
l_workflow_process	varchar2(30);
l_timeout		number := 3;
l_out_usertype		varchar2(30);
l_req_subject		varchar2(240);
l_req_body		varchar2(2000);
l_role_name		varchar2(100);
l_role_display_name	varchar2(240);
l_role_description	varchar2(240);
l_application_id	number := 520;
--
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
	l_channel_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_CHANNEL_ID' );

	l_requestor_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_REQUESTOR_ID' );

	l_item_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_ITEM_ID' );

	l_channel_name := wf_engine.GetItemAttrText(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_CHANNEL_NAME' );

	l_item_name := wf_engine.GetItemAttrText(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_ITEM_NAME' );

	l_comments := wf_engine.GetItemAttrText(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_COMMENTS' );

	l_forward_to_usertype := wf_engine.GetItemAttrText(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_FORWARD_TO_USERTYPE' );

	l_timeout := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_TIMEOUT' );

	l_workflow_process := wf_engine.GetItemAttrText(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_WORKFLOW_PROCESS' );

	--
	IF ( l_forward_to_usertype is null ) THEN
	  l_forward_to_usertype := AMV_UTILITY_PVT.G_DEFAULT;
	END IF;
	--

	-- Call Application API to retrieve an approver
	GetApprover ( 	l_channel_id,
		  		l_forward_to_usertype,
		  		l_out_usertype,
				l_forward_to_username);

	-- NOTE role name and display name are unique
	-- NOTE set the notification to type
	--
	IF l_out_usertype = AMV_UTILITY_PVT.G_SECONDARY THEN
		l_role_name := 'AMV_CHN:'||l_channel_id;
	ELSIF l_out_usertype = AMV_UTILITY_PVT.G_OWNER THEN
		l_role_name := 'AMV_APPR';
	ELSE
	 	l_role_name := l_forward_to_username;
	END IF;

	-- NOTE perform a check to validate role creation
	wf_engine.SetItemAttrText (
		itemtype=> itemtype,
      	itemkey	=> itemkey,
       	aname 	=> 'AMV_CHANNEL_APPROVER',
		avalue	=> l_role_name);
	--
	wf_engine.SetItemAttrText (
		itemtype=> itemtype,
      	itemkey => itemkey,
       	aname 	=> 'AMV_FORWARD_TO_USERNAME',
		avalue	=> l_forward_to_username);
	--

	IF l_out_usertype = AMV_UTILITY_PVT.G_DEFAULT THEN
		--
		l_forward_to_usertype := AMV_UTILITY_PVT.G_SECONDARY;
		resultout := 'COMPLETE:DEFAULT';
		--
	ELSIF l_out_usertype = AMV_UTILITY_PVT.G_SECONDARY THEN
		--
		l_forward_to_usertype := AMV_UTILITY_PVT.G_OWNER;
		resultout := 'COMPLETE:SECONDARY';
		--
	ELSIF l_out_usertype = AMV_UTILITY_PVT.G_OWNER THEN
		--
		l_forward_to_usertype := AMV_UTILITY_PVT.G_DONE;
		resultout := 'COMPLETE:OWNER';
		--
	ELSIF l_out_usertype = AMV_UTILITY_PVT.G_DONE  THEN
		--
		l_forward_to_usertype := null;
		resultout := 'COMPLETE:NONE';
		--
	END IF;
	--
	--
	wf_engine.SetItemAttrText (
			itemtype	=> itemtype,
      		itemkey  	=> itemkey,
       		aname 	=> 'AMV_FORWARD_TO_USERTYPE',
			avalue	=> l_forward_to_usertype);
	--
  	return;
	--
  END IF;
  --

  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
	--
	-- Return process to run
	--
    	resultout := 'COMPLETE:';
    	return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --

EXCEPTION
WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Selector_Approver',
			itemtype, itemkey,to_char(actid),funcmode);
	RAISE;
END Select_Approver;
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
--  <ITEM_TYPE> 	<ACTIVITY>
--  AMV_APPROVAL_PVT   	AMV_NTF_APPROVAL
--
PROCEDURE Notification_Results (itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	OUT NOCOPY  varchar2	) IS
--
l_result_code	varchar2(30);
l_status		varchar2(30);
l_group_id	pls_integer;
l_user		varchar2(30);

-- Select all lookup codes for an activities result type
cursor result_codes is
select  wfl.lookup_code result_code
from    wf_lookups wfl,
	   wf_activities wfa,
	   wf_process_activities wfpa,
	   wf_items wfi
where   wfl.lookup_type         = wfa.result_type
and     wfa.name                = wfpa.activity_name
and     wfi.begin_date          >= wfa.begin_date
and     wfi.begin_date          < nvl(wfa.end_date,wfi.begin_date+1)
and     wfpa.activity_item_type = wfa.item_type
and     wfpa.instance_id        = actid
and     wfi.item_key            = itemkey
and     wfi.item_type           = itemtype;

BEGIN

	-- Do nothing in cancel mode
	if (funcmode <> wf_engine.eng_run) then
		resultout := wf_engine.eng_null;
		return;
	end if;

  	--
  	-- RUN mode - normal process execution
  	--
  	IF (funcmode = wf_engine.eng_run) THEN
	  -- Get Notifications group_id for activity
	  Wf_Item_Activity_Status.Notification_Status(itemtype,itemkey,actid,
			l_group_id,l_user);
	  -- check for notification status and set AMV_PROCESS_ERROR to 'COMPLETE' if processing is done
  	  for result_rec in result_codes loop
	    --if (process_completed(l_group_id)) then
    		--resultout := wf_engine.eng_null;
    		--return;
	    --else
    		resultout := wf_engine.eng_completed||':'||l_result_code;
    		return;
	    --end if;
	  end loop;
  	END IF;

EXCEPTION
WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Notification_Results',
			itemtype, itemkey,to_char(actid),funcmode);
	RAISE;
END Notification_Results;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Approve_Item
--
-- Description - Publish an Item - Set Channel Item Match to approved
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
			resultout	OUT NOCOPY  varchar2	) IS
l_api_version   CONSTANT NUMBER := 1.0;
l_return_status	varchar2(1);
l_msg_count	number;
l_msg_data 	varchar2(4000);
--
l_item_id	number;
l_channel_id	number;
l_approval_status varchar2(30);
--
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
   	--
 	-- Return process to run
	--
 	l_approval_status := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_APPROVAL_STATUS' );

 	l_channel_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_CHANNEL_ID' );

 	l_item_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_ITEM_ID' );


	IF l_approval_status is null THEN
 	 AMV_CHANNEL_PVT.Set_ChannelApprovalStatus(
    		p_api_version 		=> l_api_version,
     	p_init_msg_list 	=> FND_API.G_FALSE,
     	p_commit			=> FND_API.G_FALSE,
     	p_validation_level 	=>  FND_API.G_VALID_LEVEL_FULL,
     	x_return_status	=> l_return_status,
     	x_msg_count		=> l_msg_count,
     	x_msg_data		=> l_msg_data,
     	p_check_login_user 	=> FND_API.G_FALSE,
     	p_channel_id      	=> l_channel_id,
     	p_channel_name     	=> FND_API.G_MISS_CHAR,
     	p_category_id      	=> FND_API.G_MISS_NUM,
     	p_item_id          	=> l_item_id,
     	p_approval_status  	=> AMV_UTILITY_PVT.G_APPROVED);

	 -- Check if api completes sucessfully
	 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_APPROVAL_STATUS',
								avalue	=>  'NOTIFIED');
	 	resultout := 'COMPLETE:Y';
		return;
	 ELSE
  		--
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_PROCESS_ERROR',
								avalue	=>  l_msg_data);
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_APPROVAL_STATUS',
								avalue	=>  'NOTIFIED');
	 	resultout := 'COMPLETE:N';
	 	return;
	 END IF;
	END IF;
  END IF;

  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
	--
	-- Return process to run
	--
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Approve_Item',
			itemtype,itemkey,to_char(actid),funcmode);
	RAISE;
END Approve_Item;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Approve_Subscription
--
-- Description - Approves a subscription - creates a channel in my channel
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
PROCEDURE Approve_Subscription (	itemtype	in varchar2,
							itemkey  	in varchar2,
							actid	in number,
							funcmode	in varchar2,
							resultout	OUT NOCOPY  varchar2	) IS
--
l_api_version   	CONSTANT NUMBER := 1.0;
l_return_status	varchar2(1);
l_msg_count		number;
l_msg_data 		varchar2(4000);
--
l_channel_id		number;
l_requestor_id		number;
l_mychannel_obj	amv_mychannel_pvt.amv_my_channel_obj_type;
l_mychannel_id		number;
l_approval_status varchar2(30);
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
   	--
   	-- Return process to run
   	--
 	l_approval_status := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_APPROVAL_STATUS' );

 	l_channel_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_CHANNEL_ID' );

 	l_requestor_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'AMV_REQUESTOR_ID' );

	IF l_approval_status is null THEN
	  l_mychannel_obj.my_channel_id := FND_API.G_MISS_NUM;
	  l_mychannel_obj.channel_type := FND_API.G_MISS_CHAR;
	  l_mychannel_obj.access_level_type := FND_API.G_MISS_CHAR;
	  l_mychannel_obj.user_or_group_id := l_requestor_id;
	  l_mychannel_obj.user_or_group_type :=AMV_UTILITY_PVT.G_USER;
	  l_mychannel_obj.subscribing_to_id := l_channel_id;
	  l_mychannel_obj.subscribing_to_type :=  AMV_UTILITY_PVT.G_CHANNEL;
	  l_mychannel_obj.subscription_reason_type:=AMV_UTILITY_PVT.G_SUBSCRIBED;
	  l_mychannel_obj.order_number := FND_API.G_MISS_NUM;
	  l_mychannel_obj.status := AMV_UTILITY_PVT.G_ACTIVE;
	  l_mychannel_obj.notify_flag := FND_API.G_FALSE;
	  l_mychannel_obj.notification_interval_type := FND_API.G_MISS_CHAR;
	 /*
 	 l_mychannel_obj := amv_my_channel_obj_type(
				FND_API.G_MISS_NUM,
				FND_API.G_MISS_CHAR,
				FND_API.G_MISS_CHAR,
				l_requestor_id,
				AMV_UTILITY_PVT.G_USER,
				l_channel_id,
				AMV_UTILITY_PVT.G_CHANNEL,
				AMV_UTILITY_PVT.G_SUBSCRIBED,
				FND_API.G_MISS_NUM,
				AMV_UTILITY_PVT.G_ACTIVE,
				FND_API.G_FALSE,
				FND_API.G_MISS_CHAR);
	  */

 	 AMV_MYCHANNEL_PVT.Add_Subscription(
    		p_api_version 		=> l_api_version,
     	p_init_msg_list 	=> FND_API.G_FALSE,
     	p_commit			=> FND_API.G_TRUE,
     	p_validation_level 	=>  FND_API.G_VALID_LEVEL_FULL,
     	x_return_status	=> l_return_status,
     	x_msg_count		=> l_msg_count,
     	x_msg_data		=> l_msg_data,
     	p_check_login_user 	=> FND_API.G_FALSE,
     	p_mychannel_obj	=> l_mychannel_obj,
     	x_mychannel_id		=> l_mychannel_id);

	 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_APPROVAL_STATUS',
								avalue	=>  'NOTIFIED');
	 	resultout := 'COMPLETE:Y';
		return;
	 ELSE
  		--
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_PROCESS_ERROR',
								avalue	=>  l_msg_data);
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_APPROVAL_STATUS',
								avalue	=>  'NOTIFIED');
	 	resultout := 'COMPLETE:N';
	 	return;
	 END IF;
	END IF;
  END IF;

  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Approve_Subscription',
			itemtype, itemkey,to_char(actid),funcmode);
	RAISE;
END Approve_Subscription;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Procedure
--	Reject_Item
--
-- Description - Does nothing currently
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
					actid	in number,
					funcmode	in varchar2,
					resultout	OUT NOCOPY  varchar2	) IS
--
l_api_version   CONSTANT NUMBER := 1.0;
l_return_status	varchar2(1);
l_msg_count	number;
l_msg_data 	varchar2(4000);
--
l_item_id	number;
l_channel_id	number;
l_approval_status 	varchar2(30);
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
	--
	-- Return process to run
	--
 	l_approval_status := wf_engine.GetItemAttrText(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_APPROVAL_STATUS' );

 	l_channel_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_CHANNEL_ID' );

 	l_item_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
    				itemkey => itemkey,
    				aname  	=> 'AMV_ITEM_ID' );

	IF l_approval_status is null THEN
 	 AMV_CHANNEL_PVT.Set_ChannelApprovalStatus(
    		p_api_version 		=> l_api_version,
     	p_init_msg_list 	=> FND_API.G_FALSE,
     	p_commit			=> FND_API.G_FALSE,
     	p_validation_level 	=>  FND_API.G_VALID_LEVEL_FULL,
     	x_return_status	=> l_return_status,
     	x_msg_count		=> l_msg_count,
     	x_msg_data		=> l_msg_data,
     	p_check_login_user 	=> FND_API.G_FALSE,
     	p_channel_id      	=> l_channel_id,
     	p_channel_name     	=> FND_API.G_MISS_CHAR,
     	p_category_id      	=> FND_API.G_MISS_NUM,
     	p_item_id          	=> l_item_id,
     	p_approval_status  	=> AMV_UTILITY_PVT.G_REJECTED);

	 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_APPROVAL_STATUS',
								avalue	=>  'NOTIFIED');
	 	resultout := 'COMPLETE:Y';
		return;
	 ELSE
  		--
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_PROCESS_ERROR',
								avalue	=>  l_msg_data);
  		wf_engine.SetItemAttrText ( 	itemtype 	=> itemtype,
      						   	itemkey  	=> itemkey,
 	      					   	aname  	=> 'AMV_APPROVAL_STATUS',
								avalue	=>  'NOTIFIED');
	 	resultout := 'COMPLETE:N';
	 	return;
	 END IF;
	END IF;
  END IF;

  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
	resultout := 'COMPLETE:';
	return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('AMV_WFAPPROVAL_PVT',
			'Reject_Item',
			itemtype,itemkey,to_char(actid),funcmode);
	RAISE;
END Reject_Item;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END amv_wfapproval_pvt;

/
