--------------------------------------------------------
--  DDL for Package Body XNP_WF_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_WF_SYNC" AS
/* $Header: XNPSYNCB.pls 120.2 2006/02/13 07:55:13 dputhiye ship $ */

--------------------------------------------------------------------------
-- Private Declarations
--------------------------------------------------------------------------
--
------------------------
-- CONSTANT Declarations
------------------------
--
gv_SUCCESS_RESULT	CONSTANT VARCHAR2(20) := 'SUCCESS';	-- WF Activity Success Result
gv_FAILURE_RESULT  	CONSTANT VARCHAR2(20) := 'FAILURE';	-- WF Activity Failure Result
gv_SYNC_FLAG_PARAM	CONSTANT VARCHAR2(50) := 'SYNC_REQD_FLAG';	-- Order Parameter for Porting
gv_SYNC_LABEL_PARAM	CONSTANT VARCHAR2(50) := 'SYNC_LABEL'; 	-- WI Parameter for Porting
gv_RANGE_COUNT_PARAM	CONSTANT VARCHAR2(50) := 'RANGE_COUNT';	-- WI Parameter for Porting
gv_SYNC_REQUIRED	CONSTANT VARCHAR2(1)  := 'Y';  		-- Synchronisation Required
gv_SDP_ORDER_ID_ATTR	CONSTANT VARCHAR2(50) := 'ORDER_ID';	-- WF Item Attribute - SFM Order ID
gv_LINE_ITEM_ID_ATTR	CONSTANT VARCHAR2(50) := 'LINE_ITEM_ID';-- WF Item Attribute - Line Item ID Item

-- WF Item Attribute - WI Instance ID

gv_WI_INSTANCE_ID_ATTR	CONSTANT VARCHAR2(50) := 'WORKITEM_INSTANCE_ID';
gv_SYNC_ACTIVE_STATUS	CONSTANT VARCHAR2(50) := 'ACTIVE';-- Sync Registration ACTIVE Status
gv_SYNC_ERROR_STATUS   	CONSTANT VARCHAR2(50) := 'ERROR';-- Sync Registration ERROR Status
gv_SYNC_TIMEOUT   	CONSTANT VARCHAR2(50) := 'TIMEOUT';-- Sync Registration ERROR Status
gv_SYNC_MSG		CONSTANT VARCHAR2(50) := 'SYNC';-- Synchronise Message Event
gv_SYNC_ERR_MSG		CONSTANT VARCHAR2(50) := 'SYNC_ERR';	-- Sync Error Message Event
gv_SYNC_TIMER_MSG	CONSTANT VARCHAR2(50) := 'SYNC_TIMER';	-- Sync Timer Message Event
gv_SYNC_USER_MSG	CONSTANT VARCHAR2(50) := 'XNP_SYNC_REQUEST';	-- User Display Message for Sync

--------------------------------------------------------------------------
-- Private Procedure/Function Declarations
--------------------------------------------------------------------------
------------------------------------------------------------------------
-- PROCEDURE:   create_sync_attributes()
-- PURPOSE:	Dynamically creates IS_LAST_SYNC and SDP_RESULT_CODE
--		item attributes
------------------------------------------------------------------------

PROCEDURE create_sync_attributes(
	p_itemtype IN VARCHAR2
	,p_itemkey IN VARCHAR2
	,p_actid IN NUMBER
);
--
--------------------------------------------------------------------------
-- PROCEDURE:	check_if_last()
-- PURPOSE:	checks if the work flow invoking this procedure is
--		the last one to synchronize.  Uses the parties_not_in_sync
--		column in xnp_sync_registration table to determine.
-- RETURNS	YES or NO
--------------------------------------------------------------------------

FUNCTION check_if_last (
	p_itemtype IN VARCHAR2
	,p_itemkey IN VARCHAR2
	,p_actid  IN NUMBER
) RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Description : Insert a row into the XNP_SYNC_REGISTRATION table
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Insert_Row (
	pp_sync_registration_id	IN  NUMBER
	,pp_sync_label	IN  VARCHAR2
	,pp_order_id	IN  NUMBER
	,pp_status	IN  VARCHAR2
	,pp_max_participants  	IN  NUMBER
	,pp_parties_not_in_sync	IN  NUMBER
	,po_error_code		OUT NOCOPY NUMBER
	,po_error_msg		OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------
-- Description : Get SFM Order details from SFM Provisioning WorkFlow
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Get_SDP_Workflow_Attributes (
	pp_itemtype	IN  VARCHAR2
	,pp_itemkey	IN  VARCHAR2
	,po_order_id	OUT NOCOPY NUMBER
	,po_line_item_id	OUT NOCOPY NUMBER
	,po_wi_instance_id	OUT NOCOPY NUMBER
	,po_error_code		OUT NOCOPY NUMBER
	,po_error_msg		OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------
-- Description : Procedure to manage the Synchronisation Process for
--               workflow request
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE publish_or_subscribe (
	pp_itemtype	IN  VARCHAR2
	,pp_itemkey	IN  VARCHAR2
	,pp_actid	IN  NUMBER
	,po_error_code	OUT NOCOPY NUMBER
	,po_error_msg	OUT NOCOPY VARCHAR2
	,po_result	OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------
-- Description : Procedure to set the status of a Registered Synchronisation
--               request
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Update_Sync_Status (
	pp_sync_label	IN  VARCHAR2
	,pp_status	IN  VARCHAR2
	,po_error_code	OUT NOCOPY NUMBER
	,po_error_msg	OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------
-- Procedure/Function Definitions
--------------------------------------------------------------------------
--
--------------------------------------------------------------------------
-- Description : Synchronise an Order workflow
-- Access Type : PUBLIC
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE process_sync (
	itemtype	IN  VARCHAR2
	,itemkey	IN  VARCHAR2
	,actid		IN  NUMBER
	,funcmode	IN  VARCHAR2
	,resultout	OUT NOCOPY VARCHAR2
)
IS
	lv_result		VARCHAR2(100);
	lv_message 		VARCHAR2(300);
	lv_error_code		NUMBER;
	lv_error_msg		VARCHAR2(300);
	lv_wi_instance_id	NUMBER;

	e_SyncException		EXCEPTION;

BEGIN

-- Get the SFM WI Instance ID
--

	lv_wi_instance_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype
		,itemkey  => itemkey
		,aname    => gv_WI_INSTANCE_ID_ATTR);

	IF    (funcmode = 'RUN')    THEN

		publish_or_subscribe (pp_itemtype => itemtype
			,pp_itemkey    => itemkey
			,pp_actid	   => actid
			,po_error_code => lv_error_code
			,po_error_msg  => lv_error_msg
			,po_result     => lv_result);

		IF lv_error_code <> 0 THEN
			RAISE e_SyncException;
		END IF;

		resultout := lv_result;

		RETURN;

	ELSIF (funcmode = 'CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;

	ELSE
		resultout := '';
		RETURN;
	END IF;

	EXCEPTION
		WHEN OTHERS THEN

		IF (lv_error_code <> 0) THEN
			lv_message  := TO_CHAR(lv_error_code)||':'||lv_error_msg;
		ELSE
			lv_message  := TO_CHAR(SQLCODE)||':'||SQLERRM;
		END IF;

		XNP_UTILS.NOTIFY_ERROR (p_pkg_name  => 'XNP_WF_SYNC'
			,p_proc_name  => 'SYNCHRONISE'
			,p_msg_name   => gv_SYNC_USER_MSG
			,p_workitem_instance_id => lv_wi_instance_id
			,p_tok1  => 'ERROR_TEXT'
			,p_val1  => lv_message);
		RAISE;

END process_sync;

--------------------------------------------------------------------------
-- Description : Set the status of a Synchronisation Request to ERROR
-- Access Type : PUBLIC
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Raise_Sync_Error (
	itemtype	  IN  VARCHAR2
	,itemkey       IN  VARCHAR2
	,actid         IN  NUMBER
	,funcmode      IN  VARCHAR2
	,resultout     OUT NOCOPY VARCHAR2
)
IS
	lv_result		VARCHAR2(100);
	lv_message 		VARCHAR2(300);
	lv_error_code		NUMBER;
	lv_error_msg		VARCHAR2(300);
	lv_order_id		NUMBER;
	lv_line_item_id 	NUMBER;
	lv_wi_instance_id	NUMBER;
	lv_message_id		NUMBER;
	lv_sync_label       xnp_sync_registration.sync_label%TYPE;

	e_SyncException		EXCEPTION;

BEGIN

-- Get Requird Workflow Attributes
  	--
	Get_SDP_Workflow_Attributes (pp_itemtype       => itemtype
		,pp_itemkey  => itemkey
		,po_order_id  => lv_order_id
		,po_line_item_id  => lv_line_item_id
		,po_wi_instance_id => lv_wi_instance_id
		,po_error_code => lv_error_code
		,po_error_msg  => lv_error_msg);

	IF (lv_error_code <> 0) THEN
		resultout := 'COMPLETE:'||gv_FAILURE_RESULT;
		RAISE e_SyncException;
	END IF;

	IF    (funcmode = 'RUN')    THEN

-- Get the SYNC_LABEL from the SFM Order Line Item
--
		lv_sync_label := Xdp_Engine.Get_Line_Param_Value (
			p_line_item_id   => lv_line_item_id
			,p_parameter_name => gv_SYNC_LABEL_PARAM);

	-- Update the Sync Registration Status

		Update_Sync_Status (pp_sync_label => lv_sync_label
			,pp_status     => gv_SYNC_ERROR_STATUS
			,po_error_code => lv_error_code
			,po_error_msg  => lv_error_msg);

		IF lv_error_code <> 0 THEN
			resultout := 'COMPLETE:';
			RAISE e_SyncException;
		END IF;

		resultout := 'COMPLETE:';
		RETURN;

	ELSIF (funcmode = 'CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;

	ELSE
		resultout := '';
		RETURN;
	END IF;

	EXCEPTION
		WHEN OTHERS THEN

		IF (lv_error_code <> 0) THEN
			lv_message  := TO_CHAR(lv_error_code)||':'||lv_error_msg;
		ELSE
			lv_message  := TO_CHAR(SQLCODE)||':'||SQLERRM;
		END IF;

		XNP_UTILS.NOTIFY_ERROR (p_pkg_name  => 'XNP_WF_SYNC'
			,p_proc_name  => 'RAISE_SYNC_ERROR'
			,p_msg_name   => gv_SYNC_USER_MSG
			,p_workitem_instance_id => lv_wi_instance_id
			,p_tok1  => 'ERROR_TEXT'
			,p_val1  => lv_message);
			RAISE;

END Raise_Sync_Error;

--------------------------------------------------------------------------
-- Description : Procedure to set the status of a Registered
--               Synchronisation request
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Update_Sync_Status (
	pp_sync_label		IN  VARCHAR2
	,pp_status			IN  VARCHAR2
	,po_error_code		OUT NOCOPY NUMBER
	,po_error_msg		OUT NOCOPY VARCHAR2
)
IS

	lv_status			xnp_sync_registration.status%TYPE;
	lv_error_code       NUMBER;
	lv_error_msg		VARCHAR2(300);

-- Cursor to obtain a lock on the XNP_SYNC_REGISTRATION table
--
	CURSOR lv_sync_status_cur (cv_sync_label IN VARCHAR2) IS
	SELECT status
	FROM   xnp_sync_registration
	WHERE  sync_label = cv_sync_label
	FOR UPDATE OF status;

BEGIN

 	  -- Select the current status and lock the row
 	  --
	OPEN lv_sync_status_cur (pp_sync_label);
	FETCH lv_sync_status_cur INTO lv_status;

	IF (lv_sync_status_cur%NOTFOUND) THEN
		lv_error_code := -1;
		lv_error_msg  := 'NO DATA FOUND-'||pp_sync_label;
		CLOSE lv_sync_status_cur;
		RAISE NO_DATA_FOUND;
	END IF;

	-- Update the status of the Sync Registration
  	--
  	UPDATE xnp_sync_registration
  	SET    status  = pp_status
  	WHERE CURRENT OF lv_sync_status_cur;

	po_error_code := 0;
	po_error_msg  := NULL;

	EXCEPTION
		WHEN OTHERS THEN
			po_error_code := SQLCODE;
			po_error_msg  := 'XNP_WF_SYNC.UPDATE_SYNC_STATUS-'||SQLERRM;

END Update_Sync_Status;

--------------------------------------------------------------------------
-- Description : Procedure to reset a Synchronisation request
-- Access Type : PUBLIC
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Reset_Sync_Register (
pp_sync_label		IN  VARCHAR2
,po_error_code		OUT NOCOPY NUMBER
,po_error_msg		OUT NOCOPY VARCHAR2
)
IS

	lv_status	xnp_sync_registration.status%TYPE;
	lv_error_code   NUMBER;
	lv_error_msg    VARCHAR2(300);

	-- Cursor to obtain a lock on the XNP_SYNC_REGISTRATION table
	--
	CURSOR lv_sync_status_cur (cv_sync_label IN VARCHAR2) IS
		SELECT status
		FROM   xnp_sync_registration
		WHERE  sync_label = cv_sync_label
		FOR UPDATE OF status;

BEGIN

	-- Select the current status and lock the row
	--
	OPEN lv_sync_status_cur (pp_sync_label);
	FETCH lv_sync_status_cur INTO lv_status;

	IF (lv_sync_status_cur%NOTFOUND) THEN
		lv_error_code := -1;
		lv_error_msg  := 'NO DATA FOUND-'||pp_sync_label;
		CLOSE lv_sync_status_cur;
		RAISE NO_DATA_FOUND;
	END IF;

	-- Update the status of the Sync Registration
  	--
  	UPDATE xnp_sync_registration
  	SET    status  = gv_SYNC_ACTIVE_STATUS
	      ,parties_not_in_sync = max_participants
  	WHERE CURRENT OF lv_sync_status_cur;

	po_error_code := 0;
	po_error_msg  := NULL;

	EXCEPTION
		WHEN OTHERS THEN
			po_error_code := SQLCODE;
			po_error_msg  := 'XNP_WF_SYNC.RESET_SYNC_REGISTER-'||SQLERRM;

END Reset_Sync_Register;

-- adabholk 03/2001
-- performance fix
-- Following procedure has been completely rewritten due to
-- performance issues
--------------------------------------------------------------------------
-- Description : Register an order for Synchronisation
-- Access Type : PUBLIC
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Sync_Register (
	pp_order_id		IN  NUMBER
	,po_error_code	OUT NOCOPY NUMBER
	,po_error_msg	OUT NOCOPY VARCHAR2
)
IS
	lv_sync_registration_id	  xnp_sync_registration.sync_registration_id%TYPE;
	lv_sync_label             xnp_sync_registration.sync_label%TYPE;
	lv_range_count 		  NUMBER := 0;
	lv_error_code		  NUMBER := 0;
	lv_error_msg		  VARCHAR2(300);
	e_SyncInsertException     EXCEPTION;

-- Cursor to get all Line Items for an SFM Order.
-- Used to derive SYNC_LABEL, and No Path

	CURSOR lv_line_item_cur (cv_order_id IN NUMBER) IS
		SELECT order_id, line_item_name,count(*) range_count
		FROM   xdp_order_line_items
		WHERE  order_id = cv_order_id
		GROUP BY order_id,line_item_name;

    -- Cursor to get all Line Item ID's within an Order
    -- based on the SYNC_LABEL

	CURSOR lv_line_item_id_cur (cv_order_id IN NUMBER, cv_line_item_name IN VARCHAR2) IS
		SELECT line_item_id
	FROM   xdp_order_line_items
	WHERE  order_id = cv_order_id
	AND  line_item_name = cv_line_item_name;

BEGIN

	po_error_code := 0;
	po_error_msg := NULL;

	-- Add the SYNC_REQD_FLAG parameter to the line item
  	--
	Xdp_Engine.Set_Order_Param_Value(p_order_id        => pp_order_id
  	                                ,p_parameter_name  => gv_SYNC_FLAG_PARAM
  	                                ,p_parameter_value => gv_SYNC_REQUIRED);

-- Dervice the SYNC_LABEL, MAX_PARTICIPANTS and PARTIES_NOT_IN_SYNC
-- for each Order Line Item
--
	FOR lv_line_item_rec IN lv_line_item_cur (pp_order_id) LOOP

-- Define the SYNC_LABEL and RANGE_COUNT WI Parameters
--
		lv_sync_label  := lv_line_item_rec.order_id || '-' || lv_line_item_rec.line_item_name;
		lv_range_count := lv_line_item_rec.range_count;

		FOR lv_line_item_id_rec IN lv_line_item_id_cur
				(lv_line_item_rec.order_id, lv_line_item_rec.line_item_name)
		LOOP

		-- Add SYNC_LABEL as a Line Item Parameters

			Xdp_Engine.Add_Line_Param(
				p_line_item_id  => lv_line_item_id_rec.line_item_id
				,p_parameter_name  => gv_SYNC_LABEL_PARAM
				,p_parameter_value => lv_sync_label);

  	  	-- Add RANGE_COUNT as a Line Item Parameters
  	  	--
		  	  	Xdp_Engine.Add_Line_Param(
					p_line_item_id  => lv_line_item_id_rec.line_item_id
  	  	                         ,p_parameter_name  => gv_RANGE_COUNT_PARAM
  	  	                         ,p_parameter_value => lv_range_count);
	 	END LOOP;

		-- Get the next sequence number value

		SELECT xnp_sync_registration_s.NEXTVAL
		INTO   lv_sync_registration_id
		FROM   dual;

		-- Insert a Sync Registration

		Insert_Row(pp_sync_registration_id => lv_sync_registration_id
			,pp_sync_label => lv_sync_label
			,pp_order_id => pp_order_id
			,pp_status    => gv_SYNC_ACTIVE_STATUS
			,pp_max_participants   	=> lv_range_count
			,pp_parties_not_in_sync	=> lv_range_count
			,po_error_code	=> po_error_code
			,po_error_msg	=> po_error_msg);

		IF po_error_code <> 0 THEN
			RETURN ;
		END IF;

	END LOOP;

	EXCEPTION
		WHEN OTHERS THEN
			po_error_code := SQLCODE;
			po_error_msg  := SQLERRM;

END Sync_Register;

--------------------------------------------------------------------------
-- Description : Procedure to manage the Synchronisation Process for a
--               workflow request
--
--               Process:
--               1.  Check is Synchronisation of the Order Line Item is
--                   required
--               2.  Start the Sync Timer for request
--               3.  Get the Sync Registration details for the request
--               4.  If we have a Sync Error the publish a SYNC_ERR Message
--               5.  If we still have participants not in Sync the Subscribe
--                   to the following messages:
--                   i)  SYNC
--                  ii)  SYNC_ERR
--                 iii)  SYNC_TIMER
--               6.  If all parties are in Sync then publish a SYNC message
--                   and complete the activity
-- Access Type  : PRIVATE
-- Overloaded   : NO
--------------------------------------------------------------------------

PROCEDURE publish_or_subscribe (
	pp_itemtype	IN  VARCHAR2
	,pp_itemkey	IN  VARCHAR2
	,pp_actid	IN  NUMBER
	,po_error_code	OUT NOCOPY NUMBER
	,po_error_msg	OUT NOCOPY VARCHAR2
	,po_result	OUT NOCOPY VARCHAR2
)
IS
	l_sync_label		xnp_sync_registration.sync_label%TYPE;
	l_status           	xnp_sync_registration.status%TYPE;
	l_max_participants 	xnp_sync_registration.max_participants%TYPE;
	l_parties_not_in_sync	xnp_sync_registration.parties_not_in_sync%TYPE;
	l_sync_reqd_flag	VARCHAR2(100);
	l_order_id         	NUMBER;
	l_line_item_id		NUMBER;
	l_wi_instance_id	NUMBER;
	l_error_code		NUMBER;
	l_error_msg		VARCHAR2(300);
	l_result		VARCHAR2(100);
	l_activity_label	VARCHAR2(100);
	l_reference_id          VARCHAR2(1024);
	l_message_id		NUMBER;

	l_sdp_result_code	VARCHAR2(1024) := NULL;
	l_last			VARCHAR2(80) ;

	-- Cursor to get The Sync Registration Details and
	-- to obtain a lock on the row

	CURSOR l_sync_reg_cur (cv_sync_label IN VARCHAR2) IS
		SELECT status, max_participants
		FROM   xnp_sync_registration
		WHERE  sync_label = cv_sync_label
		FOR UPDATE OF status, parties_not_in_sync ;

BEGIN

	l_error_code      := 0;
	l_error_msg       := NULL;

	Get_SDP_Workflow_Attributes (pp_itemtype => pp_itemtype
				,pp_itemkey => pp_itemkey
				,po_order_id => l_order_id
				,po_line_item_id => l_line_item_id
				,po_wi_instance_id	=> l_wi_instance_id
				,po_error_code => l_error_code
				,po_error_msg  => l_error_msg);

	IF (l_error_code <> 0) THEN

		RAISE_APPLICATION_ERROR(xnp_errors.g_wf_attribute_fetch_failed,
			'Failed to fetch workflow attributes, ERROR::'
			|| l_error_msg ) ;
	END IF;

	-- Get the current Workflow Activity Label

	l_activity_label := Wf_Engine.GetActivityLabel(pp_actid);

	-- Get the SYNC_LABEL from the SFM Order Line Item

	l_sync_label := Xdp_Engine.Get_Line_Param_Value (
			p_line_item_id   => l_line_item_id
			,p_parameter_name => gv_SYNC_LABEL_PARAM);

	-- Get the current sync registration details

	OPEN  l_sync_reg_cur (l_sync_label);

	FETCH l_sync_reg_cur INTO l_status, l_max_participants ;

    	IF (l_sync_reg_cur%NOTFOUND) THEN

		-- No sync information in registry

		CLOSE l_sync_reg_cur ;

		RAISE_APPLICATION_ERROR(xnp_errors.g_no_sync_info,
			'No Sync information in Sync Registry, Sync Label is::'
			|| l_sync_label ) ;

	END IF ;

	-- retrieve the IS_LAST_SYNC item type attribute

	l_last := wf_engine.GetItemAttrText(itemtype => pp_itemtype,
		itemkey  => pp_itemkey,
		aname   => 'IS_LAST_SYNC') ;

	IF (l_last = 'N') THEN

		-- Subscriber for a SYNC Message

		Xnp_Event.Subscribe(p_msg_code => gv_SYNC_MSG
			,p_reference_id      => l_sync_label || TO_CHAR(pp_actid)
			,p_process_reference => pp_itemtype||':'||pp_itemkey
					||':'||l_activity_label
			,p_procedure_name    => 'XNP_EVENT.RESUME_WORKFLOW'
			,p_callback_type     => 'PL/SQL'
			,p_order_id          => l_order_id
			,p_wi_instance_id    => l_wi_instance_id);

		-- Subscribe for a SYNC_ERR Message

		Xnp_Event.Subscribe(p_msg_code => gv_SYNC_ERR_MSG
			,p_reference_id      => l_sync_label || TO_CHAR(pp_actid)
			,p_process_reference => pp_itemtype||':'||pp_itemkey
				||':'||l_activity_label
			,p_procedure_name => 'XNP_EVENT.RESUME_WORKFLOW'
			,p_callback_type => 'PL/SQL'
			,p_order_id => l_order_id
			,p_wi_instance_id => l_wi_instance_id);

		l_result        := 'NOTIFIED';

        ELSE

		-- Last workflow to synchronize!!

		-- Conditionally Publish a SYNC or SYNC_ERR message
		-- to the Event Manager

		-- get the SDP_RESULT_CODE item attribute

		l_sdp_result_code :=
			wf_engine.GetItemAttrText(itemtype => pp_itemtype,
				itemkey  => pp_itemkey,
				aname   => 'SDP_RESULT_CODE') ;

		IF (l_status = gv_SYNC_ACTIVE_STATUS) THEN

			xnp_Sync_u.Publish(xnp$sync_label => l_sync_label
				,xnp$sdp_result_code => l_sdp_result_code
				,p_reference_id => l_sync_label || TO_CHAR(pp_actid)
				,p_opp_reference_id => l_sync_label || TO_CHAR(pp_actid)
				,p_consumer_list => NULL
				,p_order_id => l_order_id
				,p_wi_instance_id => l_wi_instance_id
				,p_sender_name => pp_itemtype||'-'||pp_itemkey
				,x_message_id => l_message_id
				,x_error_code => l_error_code
				,x_error_message => l_error_msg);

			IF (l_sdp_result_code IS NOT NULL) THEN
				l_result := 'COMPLETE:' || l_sdp_result_code;
			ELSE
				l_result := 'COMPLETE:' || gv_SYNC_MSG ;
			END IF ;

		ELSE

			-- Publish a SYNC_ERR_MSG to the Event Manager

			xnp_Sync_Err_u.Publish(xnp$sync_label     => l_sync_label
				,xnp$sdp_result_code => l_sdp_result_code
				,p_reference_id => l_sync_label || TO_CHAR(pp_actid)
				,p_opp_reference_id => l_sync_label || TO_CHAR(pp_actid)
				,p_consumer_list=> NULL
				,p_order_id => l_order_id
				,p_wi_instance_id => l_wi_instance_id
				,p_sender_name => pp_itemtype||'-'||pp_itemkey
				,x_message_id => l_message_id
				,x_error_code => l_error_code
				,x_error_message => l_error_msg);

			IF (l_sdp_result_code IS NOT NULL) THEN
				l_result := 'COMPLETE:' || l_sdp_result_code;
			ELSE
				l_result := 'COMPLETE:' || gv_SYNC_ERR_MSG ;
			END IF ;

		END IF;
			-- Reset parties_not_in_sync and status to 'ACTIVE' for other
			-- synchronizations to follow

			l_parties_not_in_sync := l_max_participants;

			l_status := gv_SYNC_ACTIVE_STATUS ;

			-- Reset Sync Registration Details

			UPDATE xnp_sync_registration
			SET    status  = l_status
				,parties_not_in_sync = l_parties_not_in_sync
			WHERE CURRENT OF l_sync_reg_cur;

			wf_engine.SetItemAttrText(itemtype => pp_itemtype
				,itemkey => pp_itemkey
				,aname => 'IS_LAST_SYNC'
				,avalue => 'N') ;


	END IF;

	CLOSE l_sync_reg_cur;
	po_error_code := l_error_code;
	po_error_msg  := l_error_msg;
	po_result     := l_result;

	EXCEPTION
		WHEN OTHERS THEN
			IF (l_sync_reg_cur%ISOPEN) THEN
				CLOSE l_sync_reg_cur ;
			END IF;
			po_error_code := SQLCODE;
			po_error_msg  := SQLERRM;

END publish_or_subscribe;

--------------------------------------------------------------------------
-- Description : Insert a row into the XNP_SYNC_REGISTRATION table
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Insert_Row (
	pp_sync_registration_id	IN  NUMBER
	,pp_sync_label	IN  VARCHAR2
	,pp_order_id	IN  NUMBER
	,pp_status	IN  VARCHAR2
	,pp_max_participants   	IN  NUMBER
	,pp_parties_not_in_sync	IN  NUMBER
	,po_error_code	OUT NOCOPY NUMBER
	,po_error_msg	OUT NOCOPY VARCHAR2
)
IS
BEGIN

	po_error_code := 0 ;
	po_error_msg := NULL ;

	INSERT INTO xnp_sync_registration (
		sync_registration_id
		,sync_label
		,order_id
		,status
		,max_participants
		,parties_not_in_sync
		,created_by
		,creation_date
		,last_updated_by
		,last_update_date
		)
	VALUES (
		pp_sync_registration_id
		,pp_sync_label
		,pp_order_id
		,pp_status
		,pp_max_participants
		,pp_parties_not_in_sync
		,fnd_global.user_id
		,sysdate
		,fnd_global.user_id
		,sysdate
	);

	EXCEPTION
		WHEN OTHERS THEN
			po_error_code := SQLCODE;
			po_error_msg  := 'XNP_WF_SYNC.INSERT_ROW-'||SQLERRM;

END Insert_Row;

--------------------------------------------------------------------------
-- Description : Get SFM Order details from SFM Provisioning WorkFlow.
--               The following 4 WF Item Attributes exist in all SFM
--               Workflows:
--                 i) ORDER_ID
--                ii) LINE_ITEM_ID
--               iii) WI_INSTANCE_ID
-- Access Type : PRIVATE
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Get_SDP_Workflow_Attributes (
	pp_itemtype	IN  VARCHAR2
	,pp_itemkey	IN  VARCHAR2
	,po_order_id	OUT NOCOPY NUMBER
	,po_line_item_id OUT NOCOPY NUMBER
	,po_wi_instance_id OUT NOCOPY NUMBER
	,po_error_code	OUT NOCOPY NUMBER
	,po_error_msg	OUT NOCOPY VARCHAR2
)
IS
	lv_error_msg		VARCHAR2(200);

BEGIN

-- SFM Order ID
--
	po_order_id := Wf_Engine.GetItemAttrNumber(itemtype => pp_itemtype
			,itemkey  => pp_itemkey
			,aname    => gv_SDP_ORDER_ID_ATTR);

	IF po_order_id IS NULL THEN
  		lv_error_msg := 'Unable to get SFM Order ID from WorkFlow';
  		RAISE NO_DATA_FOUND;
  	END IF;

	-- SFM Order Line Item ID

	po_line_item_id := Wf_Engine.GetItemAttrNumber(itemtype => pp_itemtype
				,itemkey  => pp_itemkey
				,aname    => gv_LINE_ITEM_ID_ATTR);

	IF po_line_item_id IS NULL THEN
		lv_error_msg := 'Unable to get SFM Line Item ID from WorkFlow';
  		RAISE NO_DATA_FOUND;
  	END IF;

	-- SFM Order WI Instance ID

  	po_wi_instance_id := Wf_Engine.GetItemAttrNumber(itemtype => pp_itemtype
			,itemkey  => pp_itemkey
			,aname    => gv_WI_INSTANCE_ID_ATTR);

  	IF po_wi_instance_id IS NULL THEN
  		lv_error_msg := 'Unable to get SFM Order WI Instance ID from WorkFlow';
  		RAISE NO_DATA_FOUND;
  	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			po_error_code := SQLCODE;
			po_error_msg  := SQLERRM;

END Get_SDP_Workflow_Attributes;

--------------------------------------------------------------------------
-- Description : Default Processing Logic for SYNC_ERR Event
-- Access Type : PUBLIC
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Process_Sync_Err (
p_msg_header		IN  XNP_MESSAGE.MSG_HEADER_REC_TYPE
,x_error_code		OUT NOCOPY NUMBER
,x_error_message		OUT NOCOPY VARCHAR2
)
IS
	lv_sync_label		xnp_sync_registration.sync_label%TYPE;
	lv_error_code		NUMBER;
	lv_error_msg		VARCHAR2(300);

	e_Exception			EXCEPTION;

BEGIN

	-- Get the SYNC_LABEL from the Event Message
--
	lv_sync_label := p_msg_header.reference_id;

	-- Update the XNP_SYNC_REGISTRATION status to ERROR
 	--
	Update_Sync_Status (pp_sync_label => lv_sync_label
		,pp_status     => gv_SYNC_ERROR_STATUS
		,po_error_code => lv_error_code
		,po_error_msg  => lv_error_msg);

	IF lv_error_code <> 0 THEN
		RAISE e_Exception;
	END IF;

	x_error_code    := 0;
	x_error_message := NULL;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code    := SQLCODE;
			x_error_message := 'XNP_WF_SYNC.PROCESS_SYNC_ERR-'
				||lv_error_msg||':'||SQLERRM;

END Process_Sync_Err;

--------------------------------------------------------------------------
-- Description : Default Processing Logic for SYNC_TIMER Event
-- Access Type : PUBLIC
-- Overloaded  : NO
--------------------------------------------------------------------------
--
PROCEDURE Process_Sync_Timer (
	p_msg_header	IN  XNP_MESSAGE.MSG_HEADER_REC_TYPE
	,x_error_code	OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2)

IS
	lv_sync_label		xnp_sync_registration.sync_label%TYPE;
	lv_error_code		NUMBER;
	lv_error_msg		VARCHAR2(300);

	e_Exception			EXCEPTION;

BEGIN

	-- Get the SYNC_LABEL from the Event Message
	--
	lv_sync_label := p_msg_header.reference_id;

	-- Update the XNP_SYNC_REGISTRATION status to ERROR
	--
	Update_Sync_Status (pp_sync_label => lv_sync_label
		,pp_status     => gv_SYNC_TIMEOUT
		,po_error_code => lv_error_code
		,po_error_msg  => lv_error_msg);

	IF lv_error_code <> 0 THEN
	RAISE e_Exception;
	END IF;

	x_error_code    := 0;
	x_error_message := NULL;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code    := SQLCODE;
			x_error_message := 'XNP_WF_SYNC.PROCESS_SYNC_TIMER-'
				||lv_error_msg||':'||SQLERRM;

END Process_Sync_Timer;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- PROCEDURE:	is_last_sync()
-- PURPOSE:	checks if the work flow invoking this procedure is
--		the last one to synchronize.  Uses the parties_not_in_sync
--		column in xnp_sync_registration table to determine.
--------------------------------------------------------------------------
--------------------------------------------------------------------------

PROCEDURE is_last_sync (
	itemtype	IN  VARCHAR2
	,itemkey		IN  VARCHAR2
	,actid		IN  NUMBER
	,funcmode	IN  VARCHAR2
	,resultout	OUT NOCOPY VARCHAR2
)
IS
	l_flag varchar2(80) := 'NO' ;
	e_SyncException		EXCEPTION;

BEGIN

	IF (funcmode = 'RUN') THEN
		l_flag := check_if_last (p_itemtype => itemtype
				,p_itemkey    => itemkey
				,p_actid	   => actid) ;
		resultout := 'COMPLETE:' || l_flag;
		RETURN;
	ELSIF (funcmode = 'CANCEL') THEN
				resultout := 'COMPLETE';
				RETURN;
			ELSE
				resultout := '';
				RETURN;
	END IF;

END is_last_sync;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- PROCEDURE:	check_if_last()
-- PURPOSE:		checks if the work flow invoking this procedure is
--				the last one to synchronize.  Uses the parties_not_in_sync
--				column in xnp_sync_registration table to determine.
-- RETURNS		YES or NO
--------------------------------------------------------------------------
--------------------------------------------------------------------------

FUNCTION check_if_last (
	p_itemtype IN VARCHAR2
	,p_itemkey IN VARCHAR2
	,p_actid  IN NUMBER
) RETURN VARCHAR2
IS
	l_sync_label               xnp_sync_registration.sync_label%TYPE;
	l_parties_not_in_sync      xnp_sync_registration.parties_not_in_sync%TYPE;
	l_max_participants         xnp_sync_registration.max_participants%TYPE;
	l_order_id                 NUMBER;
	l_line_item_id             NUMBER;
	l_wi_instance_id           NUMBER;
	l_error_code               NUMBER := 0;
	l_error_msg                VARCHAR2(300) := NULL;
	l_activity_label           VARCHAR2(100);
	l_timer_id		   NUMBER ;
	l_timer_contents	   VARCHAR2(32767) ;
	l_last_flag                VARCHAR2(80) := 'N' ;
	l_reference_id             VARCHAR2(1024);

	-- Cursor to get The Sync Registration Details and
	-- to obtain a lock on the row
	--

	CURSOR l_sync_reg_cur (cv_sync_label IN VARCHAR2) IS
		SELECT	parties_not_in_sync,
			max_participants
		FROM   xnp_sync_registration
		WHERE  sync_label = cv_sync_label
		FOR UPDATE OF status,
			parties_not_in_sync;
BEGIN

	Get_SDP_Workflow_Attributes (pp_itemtype => p_itemtype
				,pp_itemkey => p_itemkey
				,po_order_id => l_order_id
				,po_line_item_id => l_line_item_id
				,po_wi_instance_id	=> l_wi_instance_id
				,po_error_code => l_error_code
				,po_error_msg  => l_error_msg);

	IF (l_error_code <> 0) THEN

		RAISE_APPLICATION_ERROR(xnp_errors.g_wf_attribute_fetch_failed,
			'Failed to fetch workflow attributes, ERROR::'
			|| l_error_msg ) ;
	END IF;

	-- Get the current Workflow Activity Label

	l_activity_label := Wf_Engine.GetActivityLabel(p_actid);

	-- Get the SYNC_LABEL from the SFM Order Line Item

	l_sync_label := Xdp_Engine.Get_Line_Param_Value (
			p_line_item_id   => l_line_item_id
			,p_parameter_name => gv_SYNC_LABEL_PARAM);

	-- Get the current sync registration details

	OPEN  l_sync_reg_cur (l_sync_label);

	FETCH l_sync_reg_cur INTO l_parties_not_in_sync,
			l_max_participants ;

    	IF (l_sync_reg_cur%NOTFOUND) THEN

		-- No sync information in registry

		CLOSE l_sync_reg_cur ;

		RAISE_APPLICATION_ERROR(xnp_errors.g_no_sync_info,
			'No Sync information in Sync Registry, Sync Label is::'
			|| l_sync_label ) ;

	END IF ;


	-- dynamically create the item attributes, IS_LAST_SYNC and
	-- SDP_RESULT_CODE,  if necessary !!

	create_sync_attributes(p_itemtype => p_itemtype,
		p_itemkey => p_itemkey,
		p_actid => p_actid) ;

	-- the first WF will start the SYNC timer

	IF (l_parties_not_in_sync = l_max_participants) THEN

      		xnp_Sync_Timer_u.Fire (
			p_reference_id => l_sync_label || TO_CHAR(p_actid)
                      ,p_opp_reference_id => l_sync_label || TO_CHAR(p_actid)
                      ,p_order_id  => l_order_id
                      ,p_wi_instance_id  => l_wi_instance_id
                      ,p_sender_name => NULL
                      ,x_error_code => l_error_code
                      ,x_error_message  => l_error_msg
                      ,x_timer_id => l_timer_id
                      ,x_timer_contents  => l_timer_contents);

		IF l_error_code <> 0 THEN
			RAISE_APPLICATION_ERROR(xnp_errors.g_sync_timer_failed,
				'Failed to fire sync timer, Sync Label is::'
				|| l_sync_label ) ;


		END IF;

		wf_engine.SetItemAttrText(itemtype => p_itemtype
			,itemkey => p_itemkey
			,aname => 'SYNC_TMR_REF_ID'
			,avalue => l_sync_label || TO_CHAR(p_actid)) ;

	END IF;

	-- decrement the parties not in sync and update the registry

	l_parties_not_in_sync := l_parties_not_in_sync - 1;

	UPDATE xnp_sync_registration
	SET parties_not_in_sync = l_parties_not_in_sync
	WHERE CURRENT OF l_sync_reg_cur;


	-- check if the invoking WF is the last to synchronize
	-- if l_parties_not_in_sync is 1, then this is the last one
	-- synchronizing.

	IF (l_parties_not_in_sync = 0) THEN

		-- set the item type attribute IS_LAST_SYNC to 'Y'

		wf_engine.SetItemAttrText(itemtype => p_itemtype
			,itemkey => p_itemkey
			,aname => 'IS_LAST_SYNC'
			,avalue => 'Y') ;

		l_last_flag := 'LAST' ;

		-- Remove the Sync Timer

		-- get the reference ID

		l_reference_id := l_sync_label || TO_CHAR(p_actid);

		xnp_timer_core.remove_timer(
			        p_reference_id => l_reference_id
			        ,p_timer_message_code => 'SYNC_TIMER'
			        ,x_error_code => l_error_code
			        ,x_error_message => l_error_msg
			);

	ELSE

		wf_engine.SetItemAttrText(itemtype => p_itemtype
			,itemkey => p_itemkey
			,aname => 'IS_LAST_SYNC'
			,avalue => 'N') ;

		--l_last_flag := 'N' ;
		l_last_flag := 'OTHERS' ;

	END IF;

	CLOSE l_sync_reg_cur;

	RETURN (l_last_flag) ;

	EXCEPTION
		WHEN OTHERS THEN
			IF (l_sync_reg_cur%ISOPEN) THEN
				CLOSE l_sync_reg_cur ;
			END IF;
		RAISE ;

END check_if_last;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- PROCEDURE:   set_result_code()
-- PURPOSE:		Sets the SDP_RESULT_CODE workflow item attribute
--------------------------------------------------------------------------
--------------------------------------------------------------------------

PROCEDURE set_result_code (
    p_itemtype    IN  VARCHAR2
    ,p_itemkey    IN  VARCHAR2
	,p_result_value IN VARCHAR2
)
IS
BEGIN

	wf_engine.SetItemAttrText(itemtype => p_itemtype
			,itemkey => p_itemkey
			,aname => 'SDP_RESULT_CODE'
			,avalue => p_result_value) ;

END set_result_code;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- PROCEDURE:   syncnotif()
-- PURPOSE:	Sets the SDP_RESULT_CODE workflow item attribute
--------------------------------------------------------------------------
--------------------------------------------------------------------------

PROCEDURE syncnotif ( itemtype     in  varchar2,
	itemkey      in  VARCHAR2,
	actid        in  NUMBER,
	funcmode     in  VARCHAR2,
	result       OUT NOCOPY VARCHAR2
)
IS
	l_sdp_result_code       VARCHAR2(100);

BEGIN

	IF    funcmode = 'RUN' OR funcmode = 'RESPOND' THEN

		BEGIN

			SELECT text_value
			INTO l_sdp_result_code
			FROM WF_NOTIFICATION_ATTRIBUTES
			WHERE notification_id = WF_ENGINE.context_nid
			AND NAME = 'RESULT';

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_sdp_result_code := NULL;
		END;

		set_result_code (itemtype, itemkey, l_sdp_result_code);

		result := WF_ENGINE.eng_completed;
	ELSE

		result := WF_ENGINE.eng_completed;
	END IF;

	RETURN;

	EXCEPTION
		WHEN OTHERS THEN
			WF_CORE.CONTEXT('XNP_WF_SYNC', 'SYNCNOTIF', itemtype, itemkey,
				to_char(actid), funcmode);
		RAISE;
END syncnotif;

------------------------------------------------------------------------
-- PROCEDURE:   synchronize()
-- PURPOSE: packaged activity for the following activities
--	IS_LAST_SYNC and PROCESS_SYNC
------------------------------------------------------------------------

PROCEDURE synchronize (
    itemtype    IN  VARCHAR2
    ,itemkey        IN  VARCHAR2
    ,actid      IN  NUMBER
    ,funcmode   IN  VARCHAR2
    ,resultout  OUT NOCOPY VARCHAR2 )
IS

BEGIN

	is_last_sync(itemtype => itemtype,
		itemkey => itemkey,
		actid => actid,
		funcmode => funcmode,
		resultout => resultout) ;

	process_sync(itemtype => itemtype,
		itemkey => itemkey,
		actid => actid,
		funcmode => funcmode,
		resultout => resultout) ;

END synchronize;

------------------------------------------------------------------------
-- PROCEDURE:   create_sync_attributes()
-- PURPOSE:	Dynamically creates IS_LAST_SYNC and SDP_RESULT_CODE
--		item attributes
------------------------------------------------------------------------

PROCEDURE create_sync_attributes(
	p_itemtype IN VARCHAR2
	,p_itemkey IN VARCHAR2
	,p_actid IN NUMBER
)
IS
	l_value VARCHAR2(1024) := NULL;

BEGIN

	BEGIN

		l_value := wf_engine.GetItemAttrText(
				itemtype => p_itemtype
				,itemkey  => p_itemkey
				,aname   => 'IS_LAST_SYNC' );

		EXCEPTION
			WHEN OTHERS THEN

			-- Item attr doesn't exist yet, so create it

			IF ( wf_core.error_name = 'WFENG_ITEM_ATTR')
			THEN
				wf_core.clear;

				wf_engine.additemattr(
					itemtype => p_itemtype
					,itemkey  => p_itemkey
					,aname   => 'IS_LAST_SYNC') ;

				-- Set the value

				wf_engine.SetItemAttrText(
					itemtype => p_itemtype
					,itemkey => p_itemkey
					,aname => 'IS_LAST_SYNC'
					,avalue => 'N');

				wf_core.clear;
			ELSE
				RAISE;
			END IF;
	END;

	-- create SDP_RESULT_CODE if necessary

	BEGIN

		l_value := wf_engine.GetItemAttrText(
				itemtype => p_itemtype
				,itemkey  => p_itemkey
				,aname   => 'SDP_RESULT_CODE' );

		wf_engine.SetItemAttrText(
			itemtype => p_itemtype
			,itemkey => p_itemkey
			,aname => 'SDP_RESULT_CODE'
			,avalue => NULL);

		EXCEPTION
			WHEN OTHERS THEN

			-- Item attr doesn't exist yet, so create it

			IF ( wf_core.error_name = 'WFENG_ITEM_ATTR')
			THEN
				wf_core.clear;

				wf_engine.additemattr(
					itemtype => p_itemtype
					,itemkey  => p_itemkey
					,aname   => 'SDP_RESULT_CODE') ;

				-- Set the value to NULL

				wf_engine.SetItemAttrText(
					itemtype => p_itemtype
					,itemkey => p_itemkey
					,aname => 'SDP_RESULT_CODE'
					,avalue => NULL);

				wf_core.clear;
			ELSE
				RAISE;
			END IF;
	END;

	-- create SYNC_TMR_REF_ID if necessary

	BEGIN

		l_value := wf_engine.GetItemAttrText(
				itemtype => p_itemtype
				,itemkey  => p_itemkey
				,aname   => 'SYNC_TMR_REF_ID' );

		wf_engine.SetItemAttrText(
			itemtype => p_itemtype
			,itemkey => p_itemkey
			,aname => 'SYNC_TMR_REF_ID'
			,avalue => NULL);

		EXCEPTION
			WHEN OTHERS THEN

			-- Item attr doesn't exist yet, so create it

			IF ( wf_core.error_name = 'WFENG_ITEM_ATTR')
			THEN
				wf_core.clear;

				wf_engine.additemattr(
					itemtype => p_itemtype
					,itemkey  => p_itemkey
					,aname   => 'SYNC_TMR_REF_ID') ;

				-- Set the value to NULL

				wf_engine.SetItemAttrText(
					itemtype => p_itemtype
					,itemkey => p_itemkey
					,aname => 'SYNC_TMR_REF_ID'
					,avalue => NULL);

				wf_core.clear;
			ELSE
				RAISE;
			END IF;
	END;

END create_sync_attributes;

END xnp_wf_sync ;

/
