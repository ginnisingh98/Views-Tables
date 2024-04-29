--------------------------------------------------------
--  DDL for Package Body CS_WF_ACTIVITIES_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WF_ACTIVITIES_CUST" AS
/* $Header: cswfcstb.pls 115.8 2003/03/21 00:45:16 rmanabat ship $ */


-- --------------------------------------
-- Constants used in this package
-- --------------------------------------

-- cs_newline varchar2(1) := chr(10);
cs_separator varchar2(20) := '--------------------';


-- ***************************************************************************
-- *									     *
-- *			   Service Request Item Type			     *
-- *									     *
-- ***************************************************************************

--                   -----------------------------------------
--                   |             PUBLIC SECTION            |
--                   | Following procedures are customizable |
--                   -----------------------------------------
--

-- -------------------------------------------------------------------
-- Set_Response_Deadline
-- -------------------------------------------------------------------

  PROCEDURE Set_Response_Deadline(
		 		itemtype      VARCHAR2,
                              	itemkey       VARCHAR2,
                               	actid         NUMBER,
                               	funmode       VARCHAR2,
                               	result    OUT NOCOPY VARCHAR2 ) IS

    l_response_deadline 	DATE;
    l_default_days		NUMBER;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_response_deadline := WF_ENGINE.GetActivityAttrDate(
		itemtype	=>  itemtype,
		itemkey		=>  itemkey,
		actid		=>  actid,
		aname		=>  'RESPONSE_DEADLINE' );

      IF (l_response_deadline IS NOT NULL) AND
         (l_response_deadline > sysdate) THEN

        WF_ENGINE.SetItemAttrDate(
		itemtype	=>  itemtype,
		itemkey		=>  itemkey,
		aname		=>  'RESPONSE_DEADLINE',
		avalue		=>  l_response_deadline );

      ELSE

        l_default_days := WF_ENGINE.GetActivityAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				actid		=> actid,
				aname		=> 'DEFAULT_DAYS' );

        IF (l_default_days IS NULL) THEN
          l_default_days := 3;
        END IF;

        WF_ENGINE.SetItemAttrDate(
		itemtype	=>  itemtype,
		itemkey		=>  itemkey,
		aname		=>  'RESPONSE_DEADLINE',
		avalue		=>  sysdate + l_default_days );

      END IF;

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_CUST', 'Set_Response_Deadline',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Set_Response_Deadline;



-- ---------------------------------------------------------------------------
-- Initialize_Escalation_Hist
--   This procedure corresponds to the INITIALIZE_ESCALATION_HIST function
--   activity.  It initializes the ESCALATION_HISTORY item attribute.
-- ---------------------------------------------------------------------------

  PROCEDURE Initialize_Escalation_Hist( itemtype       VARCHAR2,
                                        itemkey        VARCHAR2,
                                        actid          NUMBER,
                                        funmode        VARCHAR2,
                                        result     OUT NOCOPY VARCHAR2 ) IS

    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_return_status	VARCHAR2(1);
    l_API_ERROR		EXCEPTION;
    l_request_id	NUMBER;
    l_owner_id		NUMBER;
    l_owner_name	VARCHAR2(240);
    l_dummy_role	VARCHAR2(100);
    l_escalation_history  VARCHAR2(5000);
    l_errmsg_name	  VARCHAR2(30);


    /****
     Changing this for performance issues due to
     excessive shared memory and non-mergeable view.
     rmanabat 03/20/03.

    CURSOR l_ServiceRequest_csr IS
      SELECT *
        FROM CS_INCIDENTS_WORKFLOW_V
       WHERE incident_id = l_request_id;

    l_ServiceRequest_rec 	l_ServiceRequest_csr%ROWTYPE;
    ****/

    /** Replacing above cursor with this. Bug 2857365. rmanabat 03/20/02 **/
    CURSOR l_ServiceRequest_csr IS
      SELECT emp.source_id
      FROM jtf_rs_resource_extns emp,
        cs_incidents_all_b inc
      WHERE inc.incident_id = l_request_id
        AND emp.resource_id = inc.incident_owner_id;

  BEGIN
    IF (funmode = 'RUN') THEN

      -- Extract the service request record
      l_request_id := WF_ENGINE.GetItemAttrNumber(
		itemtype	=> itemtype,
		itemkey		=> itemkey,
		aname		=> 'REQUEST_ID' );

      OPEN l_ServiceRequest_csr;
      --FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;
      FETCH l_ServiceRequest_csr INTO l_owner_id;

      IF (l_ServiceRequest_csr%NOTFOUND OR l_owner_id IS NULL) THEN
        l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
        raise l_API_ERROR;
      END IF;

      CLOSE l_ServiceRequest_csr;

      --
      -- Get the name of the current owner
      --
      --l_owner_id := l_ServiceRequest_rec.incident_owner_id;

      CS_WORKFLOW_PUB.Get_Employee_Role (
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id  		=>  l_owner_id,
		p_role_name		=>  l_dummy_role,
		p_role_display_name	=>  l_owner_name );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Get_Employee_Role',
			 arg1		=>  'p_employee_id=>'||
					    to_char(l_owner_id));
	l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
	raise l_API_ERROR;
      END IF;

      -- Get the translated message
      FND_MESSAGE.SET_NAME('CS', 'CS_SR_ASSIGNED_TO');
      FND_MESSAGE.Set_Token('OWNER', l_owner_name);
      l_escalation_history := FND_MESSAGE.Get;

      -- Now append the date and the separator
      l_escalation_history := cs_separator ||'
	'|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') ||'
	'|| l_escalation_history;

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'ESCALATION_HISTORY',
		avalue		=> substrb(l_escalation_history, 1, 2000));

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        close l_ServiceRequest_csr;
      END IF;
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_CUST', 'Initialize_Escalation_Hist',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Initialize_Escalation_Hist;



-- ---------------------------------------------------------------------------
-- Update_Escalation_Hist
--   This procedure corresponds to the UPDATE_ESCALATION_HIST function
--   activity.  It updates the ESCALATION_HISTORY item attribute.
-- ---------------------------------------------------------------------------

  PROCEDURE Update_Escalation_Hist( itemtype       VARCHAR2,
                                    itemkey        VARCHAR2,
                                    actid          NUMBER,
                                    funmode        VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 ) IS
    l_owner_name	VARCHAR2(240);
    l_escalation_history  VARCHAR2(5000);
    l_escalation_comment  VARCHAR2(2000);
    l_escalation_line     VARCHAR2(2000);
  BEGIN
    IF (funmode = 'RUN') THEN

      l_escalation_comment := WF_ENGINE.GetActivityAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				actid		=> actid,
				aname		=> 'ESCALATION_COMMENT' );

      l_escalation_history := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ESCALATION_HISTORY' );

      l_owner_name := WF_ENGINE.GetActivityAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				actid		=> actid,
				aname		=> 'ESCALATED_TO' );

      -- Get the translated escalation message line
      FND_MESSAGE.SET_NAME('CS', 'CS_SR_ESCALATED_TO');
      FND_MESSAGE.Set_Token('OWNER', l_owner_name);
      l_escalation_line := FND_MESSAGE.Get;

      -- Now append the date and the separator
      IF (l_escalation_comment IS NULL) THEN
	 l_escalation_history := cs_separator ||'
	   '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') ||'
	   '|| l_escalation_line ||'
	   '|| l_escalation_history;
      ELSE
	 l_escalation_history := cs_separator ||'
	   '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') ||'
	   '|| l_escalation_line ||'
	   '||'"'||l_escalation_comment||'"'||'
	   '|| l_escalation_history;
      END IF;

      -- Make sure it doesn't exceed 2000 bytes
      l_escalation_history := substrb(l_escalation_history, 1, 2000);

      -- Update item attribute
      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'ESCALATION_HISTORY',
		avalue		=> l_escalation_history );

      -- Reset escalation comment
      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'LAST_ESCALATION_COMMENT',
		avalue		=> l_escalation_comment );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'ESCALATION_COMMENT',
		avalue		=> '' );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_CUST', 'Update_Escalation_Hist',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Update_Escalation_Hist;



END CS_WF_ACTIVITIES_CUST;

/
