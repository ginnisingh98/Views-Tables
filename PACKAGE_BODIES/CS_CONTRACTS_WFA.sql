--------------------------------------------------------
--  DDL for Package Body CS_CONTRACTS_WFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTRACTS_WFA" AS
/* $Header: csctwfab.pls 115.0 99/07/16 08:55:44 porting ship  $ */
-- ***************************************************************************
-- *									     *
-- *			   Contract Item Type       			     *
-- *									     *
-- ***************************************************************************
PROCEDURE Selector
(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funmode       	IN VARCHAR2,
		result    	OUT VARCHAR2
)
IS
BEGIN
	if (funmode = 'RUN') then
		--
		-- Return process to run
		--
		result := 'REQUISITION_APPROVAL';
		return;
	end if;

	--
EXCEPTION
	when others then
		WF_CORE.context(CS_CONTRACTS_WFA.l_pkg_name,'Selector',itemtype,itemkey,actid,funmode);
		raise;
END Selector;

PROCEDURE Approve_Contract
(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funmode       	IN VARCHAR2,
		result    	OUT VARCHAR2
)
IS
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_errmsg_name	VARCHAR2(30);
    l_API_ERROR		EXCEPTION;
    l_wf_process_id	NUMBER;
    l_status_id		NUMBER;
    l_new_status	VARCHAR2(30);
    l_dummy_id		NUMBER;
    l_contract_id	NUMBER;
    l_object_version_number NUMBER;

BEGIN
    	IF (funmode = 'RUN') THEN
      	-- Get the workflow process ID
      	CS_Contract_Wf_PUB.Decode_Contract_Wf_Itemkey(
		p_api_version		=>  1.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		x_return_status		=>  l_return_status,
		x_msg_count		=>  l_msg_count,
		x_msg_data		=>  l_msg_data,
		p_itemkey		=>  itemkey,
		p_contract_id		=>  l_contract_id,
		p_wf_process_id		=>  l_wf_process_id );

      	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        		WF_CORE.context
			(
				pkg_name	=>  CS_CONTRACTS_WFA.l_pkg_name,
			 	proc_name	=>  'Decode_Contract_Wf_Itemkey',
			 	arg1		=>  'p_itemkey=>'||itemkey
			);
			l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
			raise l_API_ERROR;
      	END IF;

	CS_CONTRACTS_PUB.Update_Contract
 	(
    		p_api_version                  	=> 1.0,
    		p_init_msg_list                	=> TAPI_DEV_KIT.G_TRUE,
    		p_validation_level             	=> 100,
    		p_commit                       	=> TAPI_DEV_KIT.G_FALSE,
    		x_return_status                	=> l_return_status,
    		x_msg_count                    	=> l_msg_count,
    		x_msg_data                     	=> l_msg_data,
    		p_contract_id                  	=> l_contract_id,
    		p_contract_status_id          	=> FND_PROFILE.VALUE('CS_CONTRACTS_ACTIVE_STATUS'),
		p_last_updated_by		=> FND_GLOBAL.user_id,
		p_last_update_date		=> sysdate,
		p_last_update_login		=> FND_GLOBAL.login_id,
		x_object_version_number		=> l_object_version_number
	);

      	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        		WF_CORE.context
			(
				pkg_name	=>  CS_CONTRACTS_WFA.l_pkg_name,
			 	proc_name	=>  'Update_Contract',
			 	arg1		=>  'p_itemkey=>'||itemkey
			);
			l_errmsg_name := 'CS_WF_SR_CANT_UPDATE_STATUS';
			raise l_API_ERROR;
      	END IF;

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context(CS_CONTRACTS_WFA.l_pkg_name, 'Approve_Contract',
		      itemtype, itemkey, actid, funmode);
      RAISE;

END Approve_Contract;

-- ---------------------------------------------------------------------------
-- Reject_Contract
--   This procedure corresponds to the Reject_Contract function activity.  It
-- ---------------------------------------------------------------------------

PROCEDURE Reject_Contract
(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funmode       	IN VARCHAR2,
		result    	OUT VARCHAR2
) IS

BEGIN

    	IF (funmode = 'RUN') THEN
      		result := 'COMPLETE';
    	ELSIF (funmode = 'CANCEL') THEN
      		result := 'COMPLETE';
    	END IF;

EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(CS_CONTRACTS_WFA.l_pkg_name, 'Reject_Contract',
		      itemtype, itemkey, actid, funmode);
      RAISE;

END Reject_Contract;


-- Select_Approver
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:T' if approver is found
--		  - 'COMPLETE:F' if approver is not found
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE> <ACTIVITY>
--
PROCEDURE Select_Approver ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				result	out varchar2	) is
--
	l_forward_from_username	varchar2(30);
	l_forward_to_username	varchar2(30);
    	l_return_status		VARCHAR2(1);
    	l_msg_count		NUMBER;
    	l_msg_data		VARCHAR2(2000);
    	l_employee_id		NUMBER;
    	l_supervisor_name    	VARCHAR2(240);
    	l_supervisor_role	VARCHAR2(100);
    	l_supervisor_id 	NUMBER;
    	l_errmsg_name		VARCHAR2(30);
    	l_API_ERROR		EXCEPTION;
--
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
		l_forward_to_username := wf_engine.GetItemAttrText(
					itemtype => itemtype,
    					itemkey => itemkey,
    					aname  	=> 'FORWARD_TO_USERNAME' );

		--
		-- Retrieve the last person the requisition was forwarded
		-- to for approval.
		--
		if ( l_forward_to_username is null ) then
		--
  		  l_forward_to_username := wf_engine.GetItemAttrText(
					itemtype => itemtype,
		    			itemkey  => itemkey,
		    			aname => 'REQUESTOR_USERNAME' );
		--
		end if;
		--
		l_forward_from_username := l_forward_to_username;
		--
		wf_engine.SetItemAttrText (
				itemtype	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname		=> 'FORWARD_FROM_USERNAME',
				avalue		=>  l_forward_from_username);

		-- ***** ******** IMPORTANT ***********************************
		-- For now, SKARUPPA is the person to approve all the contract
		-- This logic should be changed by the customer by calling an API
		-- which will return a valid oracle application user to approve
		-- Contracts.
		-- ***** ******** IMPORTANT ***********************************

		l_forward_to_username := 'SKARUPPA';

		wf_engine.SetItemAttrText (
				itemtype	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 		=> 'FORWARD_TO_USERNAME',
				avalue		=>  l_forward_to_username);
		if ( l_forward_to_username is null ) then
			--
			result := 'COMPLETE:F';
			--
		else
			--
			result := 'COMPLETE:T';
			--
		end if;
	--
	end if;
	--
  	-- CANCEL mode - activity
	--
  	if (funcmode = 'CANCEL') then
		--
    		result := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		result := 'COMPLETE:';
		return;
	end if;

exception
	WHEN l_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
	WHEN OTHERS then
		WF_CORE.context(CS_CONTRACTS_WFA.l_pkg_name,'Select_Approver',itemtype,itemkey,actid,funcmode);
		raise;
end Select_Approver;



-- ***************************************************************************
-- *                                                                         *
-- *                           System: Error Item Type                       *
-- *                                                                         *
-- *  Following activities are used in the Service Request Error Process     *
-- *                                                                         *
-- ***************************************************************************


-- -------------------------------------------------------------------
-- Initialize_Errors
--   Retrieve the exception messages from the process that errored out
--   and store them in the item attributes of the error process.  Also,
--   get the role of the Workflow administrator.
-- -------------------------------------------------------------------

  PROCEDURE Initialize_Errors(    itemtype      VARCHAR2,
				  itemkey	VARCHAR2,
				  actid	        NUMBER,
				  funmode	VARCHAR2,
				  result    OUT VARCHAR2 ) IS

    l_error_item_type	VARCHAR2(8);
    l_error_itemkey	VARCHAR2(240);
    l_error_name	VARCHAR2(30);
    l_error_msg		VARCHAR2(2000);
    l_administrator	VARCHAR2(100);
    l_monitor_url	VARCHAR2(500);

  BEGIN
    IF (funmode = 'RUN') THEN

      --
      -- Get the type and the key of the process that errored out
      --
      l_error_itemkey := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_ITEM_KEY' );

      l_error_item_type := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_ITEM_TYPE' );

      --
      -- Get the error message
      --
      l_error_name := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_NAME' );

      IF (l_error_name IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('CS', l_error_name);
        l_error_msg := FND_MESSAGE.GET;
      END IF;

      --
      -- Get the workflow administrator
      --
      l_administrator := WF_ENGINE.GetItemAttrText(
				itemtype	=> l_error_item_type,
				itemkey		=> l_error_itemkey,
				aname		=> 'WF_ADMINISTRATOR' );
      --
      -- Set the item attributes of the error process
      --
      WF_ENGINE.SetItemAttrText(itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_MESSAGE',
				avalue		=> l_error_msg );

      WF_ENGINE.SetItemAttrText(itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'SERVEREQ_WF_ADMIN',
				avalue		=> l_administrator );

      l_monitor_url := WF_MONITOR.GetEnvelopeURL
		     ( x_agent		=> FND_PROFILE.Value('APPS_WEB_AGENT'),
		       x_item_type	=> l_error_item_type,
		       x_item_key	=> l_error_itemkey,
		       x_admin_mode	=> 'YES'
		     );
      WF_ENGINE.SetItemAttrText(itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'SERVEREQ_MONITOR_URL',
				avalue		=> l_monitor_url );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(CS_CONTRACTS_WFA.l_pkg_name, 'Initialize_Errors',
		      itemtype, itemkey, actid, funmode);
      RAISE;
  END Initialize_Errors;

PROCEDURE Initialize_Request
(
	itemtype	VARCHAR2,
	itemkey		VARCHAR2,
	actid		NUMBER,
	funmode		VARCHAR2,
	result		OUT VARCHAR2
)
IS
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_contract_id	NUMBER;
    l_dummy		NUMBER;
    l_return_status	VARCHAR2(1);
    l_API_ERROR		EXCEPTION;

    CURSOR l_Contract_csr IS
      SELECT *
        FROM CS_Contracts_all
       WHERE CONTRACT_ID = l_contract_id;

    l_Contract_rec 	l_Contract_csr%ROWTYPE;
    l_errmsg_name	VARCHAR2(30);

  BEGIN
    IF (funmode = 'RUN') THEN
      -- Decode the item key to get the service contract number
      CS_Contract_Wf_PUB.Decode_Contract_Wf_Itemkey(
		p_api_version		=>  1.0,
		x_return_status		=>  l_return_status,
		x_msg_count		=>  l_msg_count,
		x_msg_data		=>  l_msg_data,
		p_itemkey		=>  itemkey,
		p_contract_id		=>  l_contract_id,
		p_wf_process_id		=>  l_dummy );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        WF_CORE.context( pkg_name	=>  CS_CONTRACTS_WFA.l_pkg_name,
			 proc_name	=>  'Decode_Contract_Wf_Itemkey',
			 arg1		=>  'p_itemkey =>'||itemkey );
	l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
	raise l_API_ERROR;
      END IF;

      -- Extract the contract record
      OPEN l_Contract_csr;
      FETCH l_Contract_csr INTO l_Contract_rec;

      -- Initialize item attributes that will remain constant
      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> CS_Contract_Wf_PUB.l_itemtype,
		itemkey		=> itemkey,
		aname		=> 'CONTRACT_ID',
		avalue		=> l_Contract_rec.contract_id );

      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> CS_Contract_Wf_PUB.l_itemtype,
		itemkey		=> itemkey,
		aname		=> 'CONTRACT_NUMBER',
		avalue		=> l_Contract_rec.contract_number );

      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> CS_Contract_Wf_PUB.l_itemtype,
		itemkey		=> itemkey,
		aname		=> 'CONTRACT_AMOUNT',
		avalue		=> l_Contract_rec.contract_amount );

      CLOSE l_Contract_csr;

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context(CS_CONTRACTS_WFA.l_pkg_name, 'Initialize_Request',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Initialize_Request;



END CS_CONTRACTS_WFA;

/
