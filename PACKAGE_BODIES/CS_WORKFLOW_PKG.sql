--------------------------------------------------------
--  DDL for Package Body CS_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WORKFLOW_PKG" as
/* $Header: cswkflwb.pls 120.1 2008/01/14 12:15:43 vpremach ship $ */



-- -------------------------------------------------------------------
-- Pre_Validate_FS_Action
-- -------------------------------------------------------------------

PROCEDURE	Pre_Validate_FS_Action
(
	fs_request_id		NUMBER,
	fs_action_num		NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2
)
IS
	CURSOR l_action_csr IS
	SELECT
		it.business_process_id,
		sr.customer_id,
		sr.record_is_valid_flag record_valid,
--		act.action_effective_date effective_date,
--		act.expected_resolution_date resolution_date,
--		act.action_assignee_id assignee_id,
--		act.dispatcher_orig_syst_id employee_id,
--		act.dispatcher_orig_syst dis_orig_syst,
		it.workflow wf_name,
		(
		hl.address1 || hl.address2 || hl.address3
		) install_address
  	FROM
		CS_INCIDENTS_V sr,
--		CS_INCIDENT_ACTIONS_V act,
  		CS_INCIDENT_TYPES_VL it,
                HZ_PARTY_SITES hps,
                HZ_LOCATIONS hl
  	WHERE   it.incident_type_id = sr.incident_type_id
  		AND   sr.incident_id = fs_request_id
--  		AND   act.incident_id = fs_request_id
--  		AND   act.action_num = fs_action_num
                AND   sr.customer_id = hps.party_id
                AND   hps.party_site_id = hl.location_id;

       l_action_rec	l_Action_Csr%ROWTYPE;
BEGIN
	x_return_status := 'S';
	OPEN l_Action_Csr;
	FETCH l_Action_Csr INTO
					l_action_rec.business_process_id,
					l_action_rec.customer_id,
					l_action_rec.record_valid,
--					l_action_rec.effective_date,
--					l_action_rec.resolution_date,
--					l_action_rec.assignee_id,
--					l_action_rec.employee_id,
--  					l_action_rec.dis_orig_syst,
					l_action_rec.wf_name,
					l_action_rec.install_address;
--	IF l_action_rec.wf_name = 'FIELD_SERVICE_DISPATCH' AND
--			l_action_rec.dis_orig_syst <> 'PER' THEN
--		x_return_status := 'E';

	IF l_action_rec.wf_name = 'FIELD_SERVICE_DISPATCH' THEN
		x_return_status := 'E';
	ELSIF l_action_rec.wf_name = 'FIELD_SERVICE_DISPATCH' AND
		(
			l_action_rec.business_process_id is null or
			l_action_rec.customer_id is null or
			l_action_rec.record_valid is null or
--			l_action_rec.effective_date is null or
--			l_action_rec.resolution_date is null or
--			l_action_rec.assignee_id is null or
--			l_action_rec.employee_id is null or
			l_action_rec.install_address is null ) THEN
		x_return_status := 'A';
	END IF;
	CLOSE l_action_Csr;
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'E';
		if l_Action_Csr%ISOPEN THEN
			CLOSE l_Action_Csr;
		end if;
END Pre_Validate_FS_Action;

-- -------------------------------------------------------------------
-- Is_Servereq_Item_Active
-- -------------------------------------------------------------------

  FUNCTION Is_Servereq_Item_Active (
		p_request_number	  IN VARCHAR2,
		p_wf_process_id 	  IN NUMBER ) RETURN VARCHAR2 IS

    l_itemkey	VARCHAR2(240);
    l_dummy	VARCHAR2(1);
    l_end_date	DATE;
    l_result	VARCHAR2(1);
    l_item_type VARCHAR2(10);

    CURSOR l_itemtype_csr IS --Bug 6449697
      Select item_type
      from cs_incidents_all_b inc, cs_incident_types types, wf_activities wf
      where inc.incident_number= p_request_number
      and types.incident_type_id=inc.incident_type_id
      and wf.name=types.workflow;

    CURSOR l_servereq_csr IS
      SELECT end_date
      FROM   wf_items
--      WHERE  item_type = 'SERVEREQ'  --Commented for Bug 6449697
      WHERE  item_type = l_item_type
      AND    item_key  = l_itemkey;

  BEGIN
    --
    -- First construct the item key
    -- If we ever change the format of the itemkey, the following code
    -- must be updated
    --
    l_itemkey := p_request_number||'-'||to_char(p_wf_process_id);
    --Bug 6449697
    OPEN  l_itemtype_csr;
    FETCH l_itemtype_csr into l_item_type;
    CLOSE l_itemtype_csr;
    --
    -- An item is considered active if its end_date is NULL
    --
    OPEN l_servereq_csr;
    FETCH l_servereq_csr INTO l_end_date;
    IF ((l_servereq_csr%NOTFOUND) OR (l_end_date IS NOT NULL)) THEN
      l_result := 'N';
    ELSE
      l_result := 'Y';
    END IF;
    CLOSE l_servereq_csr;

    return l_result;

  END Is_Servereq_Item_Active;


-- -------------------------------------------------------------------
-- Get_Workflow_Display_Name
-- -------------------------------------------------------------------

  FUNCTION Get_Workflow_Disp_Name (
		p_item_type		IN VARCHAR2,
		p_process_name		IN VARCHAR2,
		p_raise_error		IN BOOLEAN    )
  RETURN VARCHAR2 IS

    l_display_name  VARCHAR2(80);

  BEGIN
    IF (p_process_name IS NULL) OR
       (p_item_type IS NULL)    THEN
      RETURN NULL;
    END IF;

    SELECT display_name INTO l_display_name
      FROM WF_RUNNABLE_PROCESSES_V
     WHERE item_type = p_item_type
       AND process_name = p_process_name;

    return l_display_name;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (p_raise_error = TRUE) THEN
	raise;
      ELSE
	return NULL;
      END IF;
  END Get_Workflow_Disp_Name;


-- -------------------------------------------------------------------
-- Start_Servereq_Workflow
--   Launch a service request workflow process.
-- -------------------------------------------------------------------

  PROCEDURE Start_Servereq_Workflow (
		p_request_number	  IN VARCHAR2,
		p_wf_process_name	  IN VARCHAR2,
		p_initiator_user_id	  IN NUMBER,
		p_initiator_resp_id	  IN NUMBER   := NULL,
		p_initiator_resp_appl_id  IN NUMBER   := NULL,
		p_workflow_process_id	 OUT NOCOPY NUMBER ) IS

    l_itemkey		VARCHAR2(240);
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_pos		NUMBER;
    l_API_ERROR		EXCEPTION;

  BEGIN
    -- establish savepoint
    SAVEPOINT start_workflow;

    -- Call the API.  Notice that we are doing a quiet commit by setting
    -- the commit flag
    CS_Workflow_PUB.Launch_Servereq_Workflow (
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_TRUE,
		p_commit		=> FND_API.G_TRUE,
		p_return_status		=> l_return_status,
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_request_number	=> p_request_number,
		p_initiator_user_id	=> p_initiator_user_id,
		p_initiator_resp_id	=> p_initiator_resp_id,
		p_initiator_resp_appl_id=> p_initiator_resp_appl_id,
		p_itemkey	  	=> l_itemkey,
                p_nowait                => FND_API.G_TRUE );

    -- Check for possible errors returned by the API
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise l_API_ERROR;
    END IF;

    l_pos := INSTR(l_itemkey, '-');
    p_workflow_process_id := SUBSTR(l_itemkey, l_pos+1);

  EXCEPTION
    WHEN l_API_ERROR THEN
      ROLLBACK TO start_workflow;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_API_ERROR');
      FND_MESSAGE.Set_Token('ERROR_MSG', l_msg_data);
      -- rmanabat 11/20/01 Fix for bug# 2102121.
      --APP_EXCEPTION.Raise_Exception;

  END Start_Servereq_Workflow;


-- -------------------------------------------------------------------
-- Abort_Servereq_Workflow
--   Abort a service request workflow process
-- -------------------------------------------------------------------

  PROCEDURE Abort_Servereq_Workflow (
		p_request_number	  IN VARCHAR2,
		p_wf_process_id		  IN NUMBER,
		p_user_id	  	  IN NUMBER ) IS

    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_API_ERROR		EXCEPTION;

  BEGIN
    SAVEPOINT abort_workflow;

    -- Call the API.  Notice that we are doing a quiet commit by setting
    -- the commit flag
    CS_Workflow_PUB.Cancel_Servereq_Workflow (
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_TRUE,
		p_commit		=> FND_API.G_TRUE,
		p_return_status		=> l_return_status,
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_request_number	=> p_request_number,
		p_wf_process_id	  	=> p_wf_process_id,
		p_user_id               => p_user_id );

    -- Check for possible errors returned by the API
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise l_API_ERROR;
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      ROLLBACK TO abort_workflow;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_API_ERROR');
      FND_MESSAGE.Set_Token('ERROR_MSG', l_msg_data);
      --APP_EXCEPTION.Raise_Exception;

  END Abort_Servereq_Workflow;



-- -------------------------------------------------------------------
-- Abort_Servereq_Workflow
--   Abort a service request workflow process
--   Overloaded procedure to return messages to the calling library CSSRISR.pld
--   rmanabat 05/08/02
-- -------------------------------------------------------------------

  PROCEDURE Abort_Servereq_Workflow (
		p_request_number	  IN VARCHAR2,
		p_wf_process_id		  IN NUMBER,
		p_user_id	  	  IN NUMBER,
                x_msg_count               OUT NOCOPY NUMBER,
                x_msg_data                OUT NOCOPY VARCHAR2 ) IS

    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_API_ERROR		EXCEPTION;

  BEGIN
    SAVEPOINT abort_workflow;

    -- Call the API.  Notice that we are doing a quiet commit by setting
    -- the commit flag
    CS_Workflow_PUB.Cancel_Servereq_Workflow (
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_TRUE,
		p_commit		=> FND_API.G_TRUE,
		p_return_status		=> l_return_status,
		p_msg_count		=> x_msg_count,
		p_msg_data		=> x_msg_data,
		p_request_number	=> p_request_number,
		p_wf_process_id	  	=> p_wf_process_id,
		p_user_id               => p_user_id );

    -- Check for possible errors returned by the API
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise l_API_ERROR;
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      ROLLBACK TO abort_workflow;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_API_ERROR');
      --FND_MESSAGE.Set_Token('ERROR_MSG', l_msg_data);
      FND_MESSAGE.Set_Token('ERROR_MSG', x_msg_data);
      --APP_EXCEPTION.Raise_Exception;

  END Abort_Servereq_Workflow;

----------------------------------------------------------------------
-- Is_Action_Item_Active
----------------------------------------------------------------------

FUNCTION Is_Action_Item_Active
( p_request_id		IN NUMBER,
  p_action_number	IN NUMBER,
  p_wf_process_id	IN NUMBER
)
RETURN VARCHAR2
IS
  l_itemkey	VARCHAR2(240);
  l_dummy	VARCHAR2(1);
  l_end_date	DATE;
  l_result	VARCHAR2(1);

  CURSOR l_sraction_csr IS
    SELECT end_date
    FROM   wf_items
    WHERE  item_type = 'SRACTION'
    AND    item_key  = l_itemkey;

BEGIN
  --
  -- First construct the item key
  -- If we ever change the format of the itemkey, the following code
  -- must be updated
  --
  l_itemkey := p_request_id || '-' || p_action_number || '-' || p_wf_process_id;

  --
  -- An item is considered active if its end_date is NULL
  --
  OPEN l_sraction_csr;
  FETCH l_sraction_csr INTO l_end_date;
  IF ((l_sraction_csr%NOTFOUND) OR (l_end_date IS NOT NULL)) THEN
    l_result := 'N';
  ELSE
    l_result := 'Y';
  END IF;
  CLOSE l_sraction_csr;

  RETURN l_result;

END Is_Action_Item_Active;


----------------------------------------------------------------------
-- Start_Action_Workflow
--   Launch a service request action workflow process.
----------------------------------------------------------------------

PROCEDURE Start_Action_Workflow
( p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_initiator_user_id		IN	NUMBER,
  p_initiator_resp_id		IN	NUMBER   := NULL,
  p_initiator_resp_appl_id	IN	NUMBER   := NULL,
  p_launched_by_dispatch	IN	VARCHAR2 := 'N',
  p_workflow_process_id		OUT	NOCOPY NUMBER
)
IS
  l_itemkey			VARCHAR2(240);
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);
  l_launched_by_dispatch	VARCHAR2(1);
  l_pos				NUMBER;
  l_exc_api_error		EXCEPTION;
  EMPLOYEE_NOT_FOUND	EXCEPTION;
  ACTION_NOT_VALID		EXCEPTION;

BEGIN
  -- Establish savepoint
  SAVEPOINT Start_Action_Workflow;

  -- Determine whether this call is made from the Dispatch window
  IF (p_launched_by_dispatch = 'Y') THEN
    l_launched_by_dispatch := FND_API.G_TRUE;
  ELSE
    l_launched_by_dispatch := FND_API.G_FALSE;
  END IF;
  -- Call the API. Notice that we are doing a quiet commit by setting
  -- the commit flag

	Pre_Validate_FS_Action
	(
		fs_request_id		=> p_request_id,
		fs_action_num		=> p_action_number,
		x_return_status	=> l_return_status
	);
	if l_return_status = 'E' then
		RAISE EMPLOYEE_NOT_FOUND;
	elsif l_return_status = 'A' then
		RAISE ACTION_NOT_VALID;
	end if;

  /*CS_Workflow_PUB.launch_Action_Workflow
    (
	p_api_version		=> 1.0,
      p_init_msg_list		=> FND_API.G_TRUE,
      p_commit			=> FND_API.G_TRUE,
      p_return_status		=> l_return_status,
      p_msg_count		=> l_msg_count,
      p_msg_data		=> l_msg_data,
      p_request_id		=> p_request_id,
      p_action_number		=> p_action_number,
      p_initiator_user_id	=> p_initiator_user_id,
      p_initiator_resp_id	=> p_initiator_resp_id,
      p_initiator_resp_appl_id	=> p_initiator_resp_appl_id,
      p_launched_by_dispatch	=> l_launched_by_dispatch,
      p_itemkey		  	=> l_itemkey,
      p_nowait	                => FND_API.G_TRUE
    );*/

  -- Check for possible errors returned by the API
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE l_exc_api_error;
  END IF;

  l_pos := INSTR(l_itemkey, '-');
  l_pos := INSTR(l_itemkey, '-', l_pos+1);
  p_workflow_process_id := SUBSTR(l_itemkey, l_pos+1);

EXCEPTION
  WHEN l_exc_api_error THEN
    ROLLBACK TO Start_Action_Workflow;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_API_ERROR');
    FND_MESSAGE.Set_Token('ERROR_MSG', l_msg_data);
    APP_EXCEPTION.Raise_Exception;
  WHEN EMPLOYEE_NOT_FOUND THEN
    ROLLBACK TO Start_Action_Workflow;
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_EMP_NOT_FOUND');
    APP_EXCEPTION.Raise_Exception;
  WHEN ACTION_NOT_VALID THEN
    ROLLBACK TO Start_Action_Workflow;
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_ACT_NOT_VALID');
    APP_EXCEPTION.Raise_Exception;

END Start_Action_Workflow;


----------------------------------------------------------------------
-- Abort_Action_Workflow
--   Abort a service request action workflow process
----------------------------------------------------------------------

PROCEDURE Abort_Action_Workflow
( p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_wf_process_id		IN	NUMBER,
  p_abort_user_id		IN	NUMBER,
  p_launched_by_dispatch	OUT	NOCOPY VARCHAR2
)
IS
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);
  l_launched_by_dispatch	VARCHAR2(1);
  l_exc_api_error		EXCEPTION;
BEGIN
  SAVEPOINT Abort_Action_Workflow;

  -- Call the API. Notice that we are doing a quiet commit by setting
  -- the commit flag
  CS_Workflow_PUB.Cancel_Action_Workflow
    ( p_api_version		=> 1.0,
      p_init_msg_list		=> FND_API.G_TRUE,
      p_commit			=> FND_API.G_TRUE,
      p_return_status		=> l_return_status,
      p_msg_count		=> l_msg_count,
      p_msg_data		=> l_msg_data,
      p_request_id		=> p_request_id,
      p_action_number		=> p_action_number,
      p_wf_process_id		=> p_wf_process_id,
      p_abort_user_id		=> p_abort_user_id,
      p_launched_by_dispatch	=> l_launched_by_dispatch
    );

  -- Check for possible errors returned by the API
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE l_exc_api_error;
  END IF;

  IF FND_API.To_Boolean(l_launched_by_dispatch) THEN
    p_launched_by_dispatch := 'Y';
  ELSE
    p_launched_by_dispatch := 'N';
  END IF;

EXCEPTION
  WHEN l_exc_api_error THEN
    ROLLBACK TO Abort_Action_Workflow;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_API_ERROR');
    FND_MESSAGE.Set_Token('ERROR_MSG', l_msg_data);
    APP_EXCEPTION.Raise_Exception;

END Abort_Action_Workflow;






/********************************************************************
-- Start_Servereq_Workflow
--   Launch a service request workflow process.
--   Overloaded procedure to return any messages back to the calling library
--   CSSRISR.pld  . rmanabat 05/08/02
--
--   11.5.9 . rmanabat . 03/13/03.
--   This manually launches the workflow from the UI by raising the event.
--   if the workflow was not launched via the workflow event, we will try
--   to launch the workflow using the old workflow API calls.
********************************************************************/

  PROCEDURE Start_Servereq_Workflow (
                p_request_number          IN VARCHAR2,
                p_wf_process_name         IN VARCHAR2,
                p_initiator_user_id       IN NUMBER,
                p_initiator_resp_id       IN NUMBER   := NULL,
                p_initiator_resp_appl_id  IN NUMBER   := NULL,
                p_workflow_process_id    OUT NOCOPY NUMBER,
                x_msg_count              OUT NOCOPY NUMBER,
                x_msg_data               OUT NOCOPY VARCHAR2 ) IS

    l_itemkey           VARCHAR2(240);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_pos               NUMBER;
    l_API_ERROR         EXCEPTION;

    l_workflow_process_id	NUMBER;

    l_event_id	NUMBER;
    l_event_key VARCHAR2(60);
    l_param_list                wf_parameter_list_t;
    l_initiator_role	VARCHAR2(100);
    l_dummy                     VARCHAR2(240);
    l_administrator             VARCHAR2(100);
    x_wf_process_id NUMBER;


    CURSOR l_sel_request_csr IS
        SELECT nvl(status.close_flag,'N') close_flag,
                inc.workflow_process_id,
                cit.AUTOLAUNCH_WORKFLOW_FLAG,
                cit.WORKFLOW,
                inc.resource_type,
                inc.incident_owner_id,
                inc.incident_id,
                inc.object_version_number
        FROM   cs_incident_statuses status,
                cs_incidents_all_b inc,
                cs_incident_types cit
        WHERE  inc.incident_number = p_request_number
               AND inc.incident_status_id = status.incident_status_id
               and cit.incident_type_id = inc.incident_type_id;

    l_sel_request_rec   l_sel_request_csr%ROWTYPE;


  BEGIN
    -- establish savepoint
    SAVEPOINT start_workflow;

    --INSERT INTO rm_tmp values (p_request_number, 'In 2nd overloaded Start_Servereq_Workflow,p_wf_manual_launch =Y',rm_tmp_seq.nextval);

    --  Derive Role from User ID
    IF (p_initiator_user_id IS NOT NULL) THEN
      CS_WF_AUTO_NTFY_UPDATE_PKG.get_fnd_user_role
           ( p_fnd_user_id        => p_initiator_user_id,
             x_role_name          => l_initiator_role,
             x_role_display_name  => l_dummy );
    END IF;


    wf_event.AddParameterToList(p_name => 'REQUEST_NUMBER',
                              p_value => p_request_number,
                              p_parameterlist => l_param_list);

    wf_event.AddParameterToList(p_name => 'USER_ID',
                              p_value => p_initiator_user_id,
                              p_parameterlist => l_param_list);

    wf_event.AddParameterToList(p_name => 'RESP_ID',
                              p_value => p_initiator_resp_id,
                              p_parameterlist => l_param_list);

    wf_event.AddParameterToList(p_name => 'RESP_APPL_ID',
                              p_value => p_initiator_resp_appl_id,
                              p_parameterlist => l_param_list);

    wf_event.AddParameterToList(p_name => 'INITIATOR_ROLE',
                              p_value => l_initiator_role,
                              p_parameterlist => l_param_list);

    wf_event.AddParameterToList(p_name => 'MANUAL_LAUNCH',
                              p_value => 'Y',
                              p_parameterlist => l_param_list);



    BEGIN
      l_administrator := FND_PROFILE.VALUE('CS_WF_ADMINISTRATOR');

      wf_event.AddParameterToList(p_name => 'WF_ADMINISTRATOR',
                                p_value => l_administrator,
                                p_parameterlist => l_param_list);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;



    SELECT cs_wf_process_id_s.nextval
    INTO l_event_id
    FROM dual;

    -- Construct the unique event key
    l_event_key := p_request_number ||'-'||to_char(l_event_id) || '-EVT';

 --INSERT INTO rm_tmp values (p_request_number, 'Raising Update event from start_servereq ',rm_tmp_seq.nextval);
 --INSERT INTO rm_tmp values (p_request_number, 'oracle.apps.cs.sr.ServiceRequest.updated'||' l_event_key= '|| l_event_key ,rm_tmp_seq.nextval);

    -- Raise Workflow Business Event based on the event code.
    wf_event.raise(p_event_name => 'oracle.apps.cs.sr.ServiceRequest.updated',
                   p_event_key  => l_event_key,
                   p_parameters => l_param_list);



    IF (CS_Workflow_PKG.Is_Servereq_Item_Active
                         (p_request_number  => p_request_number,
                          p_wf_process_id   => l_event_id)  = 'Y') THEN



 --INSERT INTO rm_tmp values (p_request_number, 'Event successfully raised from start_servereq ',rm_tmp_seq.nextval);


      UPDATE CS_INCIDENTS_ALL_B set WORKFLOW_PROCESS_ID = l_event_id
      WHERE INCIDENT_ID = l_sel_request_rec.incident_id;

      COMMIT WORK;
      --commit;

      p_workflow_process_id := l_event_id;


    /*******************************
     Workflow was not launched via call to the raise event (BES).
     Will try to launch the workflow using the old API calls.
    ********************************/

    ELSIF (p_wf_process_name IS NOT NULL) THEN

 --INSERT INTO rm_tmp values (p_request_number, 'Event UNsuccessfull, attempting to Start WF from start_servereq ',rm_tmp_seq.nextval);

      OPEN l_sel_request_csr;
      FETCH l_sel_request_csr INTO l_sel_request_rec;


      IF (l_sel_request_csr%FOUND AND
          l_sel_request_rec.resource_type = 'RS_EMPLOYEE' AND
          l_sel_request_rec.incident_owner_id IS NOT NULL AND
          l_sel_request_rec.close_flag <> 'Y' ) THEN

        /*************
        CS_Workflow_PKG.Start_Servereq_Workflow(
                                p_request_number        => p_request_number,
                                p_wf_process_name       => p_wf_process_name,
                                p_initiator_user_id     => p_initiator_user_id,
                                p_initiator_resp_id     => p_initiator_resp_id,
                                p_initiator_resp_appl_id=> p_initiator_resp_appl_id,
                                --
                                -- This flag should be set to 'N' when called from the
                                -- Update/Create SR api, or any other API. This is only
                                -- set to 'Y' when called from the tools menu of the SR UI.
                                --
                                p_wf_manual_launch      => 'N',
                                p_workflow_process_id   => x_wf_process_id,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data);

        p_workflow_process_id := x_wf_process_id;
        *********/


        CS_Workflow_PUB.Launch_Servereq_Workflow (
                  p_api_version           => 1.0,
                  p_init_msg_list         => FND_API.G_TRUE,
                  p_commit                => FND_API.G_TRUE,
                  p_return_status         => l_return_status,
                  p_msg_count             => x_msg_count,
                  p_msg_data              => x_msg_data,
                  p_request_number        => p_request_number,
                  p_initiator_user_id     => p_initiator_user_id,
                  p_initiator_resp_id     => p_initiator_resp_id,
                  p_initiator_resp_appl_id=> p_initiator_resp_appl_id,
                  p_itemkey               => l_itemkey,
                  p_nowait                => FND_API.G_TRUE );

        -- Check for possible errors returned by the API
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise l_API_ERROR;
        END IF;

        l_pos := INSTR(l_itemkey, '-');
        p_workflow_process_id := SUBSTR(l_itemkey, l_pos+1);


      END IF;

      CLOSE l_sel_request_csr;

    END IF;


  EXCEPTION
    WHEN l_API_ERROR THEN
      ROLLBACK TO start_workflow;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_API_ERROR');
      FND_MESSAGE.Set_Token('ERROR_MSG', x_msg_data);
      --FND_MESSAGE.Set_Token('ERROR_MSG', l_msg_data);
      -- rmanabat 11/20/01 Fix for bug# 2102121.
      --APP_EXCEPTION.Raise_Exception;

  END Start_Servereq_Workflow;


END CS_Workflow_PKG;

/
