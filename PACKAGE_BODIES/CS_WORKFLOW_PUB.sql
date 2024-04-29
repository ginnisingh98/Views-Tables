--------------------------------------------------------
--  DDL for Package Body CS_WORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WORKFLOW_PUB" AS
/* $Header: cspwfb.pls 120.2 2008/01/14 12:14:16 vpremach ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_Workflow_PUB';

/****************************************************************************
			    Forward Declaration
 ****************************************************************************/

  PROCEDURE Get_Employee_ID (
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2   ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_api_name		  IN VARCHAR2,
		p_employee_id	          IN NUMBER     ,
		p_emp_last_name	 	  IN VARCHAR2   ,
		p_emp_first_name	  IN VARCHAR2   ,
		p_employee_id_out	 OUT NOCOPY NUMBER );

------------------------------------------------------------------------------
--  Procedure	: Get_Fnd_User_Role
--  Description	: Get the Workflow role of the given FND user
--  Parameters	:
--  IN		: p_fnd_user_id		IN	NUMBER		Required
--			Corresponds to the column USER_ID in the table
--			FND_USER, and identifies the Oracle Applications user
--  OUT		: x_role_name		OUT	VARCHAR2(100)
--			Workflow role name of the Applications user
--		  x_role_display_name	OUT	VARCHAR2(100)
--			Workflow role display name of the Applications user
------------------------------------------------------------------------------

PROCEDURE Get_Fnd_User_Role
  ( p_fnd_user_id	IN	NUMBER,
    x_role_name		OUT	NOCOPY VARCHAR2,
    x_role_display_name	OUT	NOCOPY VARCHAR2 );

/****************************************************************************
			   API Procedure Bodies
 ****************************************************************************/

-- -------------------------------------------------------------------
-- Launch_Servereq_Workflow
-- -------------------------------------------------------------------

  PROCEDURE Launch_Servereq_Workflow (
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_commit		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_request_number	  IN VARCHAR2,
		p_initiator_user_id	  IN NUMBER    ,
		p_initiator_resp_id	  IN NUMBER    ,
		p_initiator_resp_appl_id  IN NUMBER    ,
		p_itemkey	  	 OUT NOCOPY VARCHAR2,
                p_nowait                  IN VARCHAR2  ) IS

    l_api_name	        CONSTANT VARCHAR2(30) := 'Launch_Servereq_Workflow';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_administrator	VARCHAR2(100);
    l_dummy		VARCHAR2(240);
    l_wf_process_id	NUMBER;
    l_request_id	NUMBER;
    l_nowait            BOOLEAN := FALSE;
    l_workflow_proc	VARCHAR2(30);
    l_web_workflow	VARCHAR2(30);
    l_web_entry_flag	VARCHAR2(1);
    l_close_flag	VARCHAR2(1);
    l_msg_index_out	NUMBER;
    l_resp_id           NUMBER;
    l_resp_appl_id      NUMBER;
    l_useR_id           NUMBER;

--add an out parametr to Update_ServiceRequest API for wf_process_id
    out_wf_process_id	NUMBER;

    l_ADMINISTRATOR_NOT_SET	EXCEPTION;
    l_RESET_ADMINISTRATOR	EXCEPTION;
    l_WORKFLOW_IN_PROGRESS	EXCEPTION;
    l_SR_NO_WORKFLOW		EXCEPTION;
    l_SR_CLOSED_STATUS		EXCEPTION;

    CURSOR l_WorkflowProcID_csr IS
	SELECT cs_wf_process_id_s.nextval
	  FROM dual;

    CURSOR l_ServeReq_csr IS
      SELECT inc.incident_id,
             inc.workflow_process_id,
             inc.object_version_number,
             type.workflow,
             status.close_flag
      FROM cs_incidents_all_b inc,
           cs_incident_types type,
           cs_incident_statuses status
      WHERE inc.incident_number = p_request_number
        AND type.incident_type_id = inc.incident_type_id
        AND status.incident_status_id = inc.incident_status_id;

    CURSOR l_Wf_ItemType IS -- Bug 6449697
       SELECT item_type
       FROM wf_activities
       WHERE name = l_workflow_proc
       AND  trunc(NVL(begin_date,sysdate)) <= trunc(sysdate)
       AND trunc(NVL(end_date,sysdate)) >= trunc(sysdate);

-- fix for # 1348309
-- do not need to update from workflow API
--	 FOR UPDATE OF workflow_process_id;

    /*** This cursor is the same as above. rmanabat . 032403 .
    CURSOR l_ServeReq_NW_csr IS
      SELECT incident_id, workflow_process_id,object_version_number
 	FROM cs_incidents_all_b
       WHERE incident_number = p_request_number;
    ****/

--fix for # 1348309
-- do not need to update from workflow API
--	 FOR UPDATE OF workflow_process_id NOWAIT;
    l_itemtype          VARCHAR2(50);
    l_itemkey		VARCHAR2(240);
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_initiator_role	VARCHAR2(100);

    -- For audit record
    -- This is obsolete. rmanabat 11/21/02
    --l_change_flags_rec     CS_ServiceRequest_PVT.audit_flags_rec_type;

    l_service_request_rec  CS_ServiceRequest_PVT.service_request_rec_type;
    l_notes  CS_SERVICEREQUEST_PVT.notes_table;
    l_contacts  CS_SERVICEREQUEST_PVT.contacts_table;
    l_object_version_number    number;
    l_interaction_id           number;



  BEGIN
    -- API savepoint
    SAVEPOINT Launch_Workflow_PUB;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Set nowait option
    IF FND_API.to_Boolean( p_nowait ) THEN
      l_nowait := TRUE;
    END IF;

    -- Get the Workflow Administrator Role
    -- rmanabat 11/20/01 . Fix for bug 2102121
    BEGIN
      l_administrator := FND_PROFILE.VALUE('CS_WF_ADMINISTRATOR');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                null;
    END;

    IF (l_administrator IS NULL) THEN
      raise l_ADMINISTRATOR_NOT_SET;
    END IF;

    -- Taking this validation out because of performance issues.
    -- Just need to check if workflow administrator is set.
    -- bug 2196135 . rmanabat 01/25/02
    /****************************
    ELSE
      BEGIN

	SELECT 'x' INTO l_dummy
	  FROM WF_ROLES
	 WHERE name = l_administrator;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  -- Invalid Administrator Role
	  raise l_RESET_ADMINISTRATOR;

	WHEN TOO_MANY_ROWS THEN
	  -- Okay here
	  null;
      END;
    END IF;
    ***********************************/

    /**** These cursors are the same . rmanabat 032403. ****/
    /****
    -- Get the last workflow process ID of this request and lock the record
    IF ( l_nowait = TRUE ) THEN
      OPEN l_ServeReq_NW_csr;
      FETCH l_ServeReq_NW_csr INTO l_request_id, l_wf_process_id,
	 l_object_version_number;
    ELSE
      OPEN l_ServeReq_csr;
      FETCH l_ServeReq_csr INTO l_request_id, l_wf_process_id,
		  l_object_version_number;
    END IF;
    ****/

    OPEN l_ServeReq_csr;
    FETCH l_ServeReq_csr
    INTO l_request_id, l_wf_process_id, l_object_version_number,
         l_workflow_proc, l_close_flag;
    CLOSE l_ServeReq_csr;

    -- Verify that the workflow is not active
    IF (l_wf_process_id IS NOT NULL) THEN
      IF (CS_Workflow_PKG.Is_Servereq_Item_Active(
			p_request_number    =>  p_request_number,
			p_wf_process_id	    =>  l_wf_process_id ) = 'Y') THEN
        raise l_WORKFLOW_IN_PROGRESS;
      END IF;
    END IF;

    -- nmhatre 03/24/2000
    -- commented out to take care of bug# 1213076.
    -- We are not using web workflow any more so we need not select
    -- web_workflow and sr_creation_channel columns.

    -- Get the workflow process name for this request from the request type
    -- SELECT type.workflow, type.web_workflow, inc.sr_creation_channel
    --  INTO l_workflow_proc, l_web_workflow, l_web_entry_flag
    --  FROM cs_incident_types type, cs_incidents_all_vl inc
    -- WHERE inc.incident_number = p_request_number
    --   AND inc.incident_type_id = type.incident_type_id;

    -- Get the workflow process name for this request from the request type

    /**** Combining this with the l_ServeReq_csr cursor above. ***/
    /**** rmanabat. 032403 .
    SELECT type.workflow
      INTO l_workflow_proc
	 FROM cs_incident_types type, cs_incidents_all_vl inc
     WHERE inc.incident_number = p_request_number
	  AND inc.incident_type_id = type.incident_type_id;
    ****/

    -- Select workflow specific to web service requests
    -- IF (l_web_entry_flag = 'Y') THEN
      -- l_workflow_proc := l_web_workflow;
    -- END IF;

    IF (l_workflow_proc IS NULL) THEN
      raise l_SR_NO_WORKFLOW;
    END IF;

    -- Verify that the status of the service request is not 'Closed'

    /**** Combining this with the l_ServeReq_csr cursor above. ***/
    /**** rmanabat. 032403 .
    SELECT status.close_flag INTO l_close_flag
      FROM cs_incident_statuses status, cs_incidents_all_vl inc
     WHERE inc.incident_number = p_request_number
       AND inc.incident_status_id = status.incident_status_id;
    ****/

    IF (l_close_flag = 'Y') THEN
      raise l_SR_CLOSED_STATUS;
    END IF;

    -- Get the new workflow process ID
    OPEN  l_WorkflowProcID_csr;
    FETCH l_WorkflowProcID_csr INTO l_wf_process_id;
    CLOSE l_WorkflowProcID_csr;

    -- Construct the unique item key
    l_itemkey := p_request_number||'-'||to_char(l_wf_process_id);
   --dbms_output.put_line('item-key ' || l_itemkey);

    -- Get the process initiator's workflow role name
    IF (p_initiator_user_id IS NOT NULL) THEN
       get_fnd_user_role
	 ( p_fnd_user_id	=> p_initiator_user_id,
	   x_role_name		=> l_initiator_role,
	   x_role_display_name	=> l_dummy );
    END IF;

    IF p_initiator_user_id = -1 OR
       p_initiator_user_id IS NULL OR
       p_initiator_user_id = FND_API.G_MISS_NUM THEN
       l_user_id := FND_GLOBAL.User_Id;
    ELSE
       l_user_id := p_initiator_user_id;
    END IF;


    IF p_initiator_resp_id = -1 OR
       p_initiator_resp_id IS NULL OR
       p_initiator_resp_id = FND_API.G_MISS_NUM THEN
       l_resp_id := FND_GLOBAL.resp_Id;
    ELSE
       l_resp_id := p_initiator_resp_id;
    END IF;


    IF p_initiator_resp_appl_id = -1 OR
       p_initiator_resp_appl_id IS NULL OR
       p_initiator_resp_appl_id = FND_API.G_MISS_NUM THEN
       l_resp_appl_id := FND_GLOBAL.resp_appl_Id;
    ELSE
       l_resp_appl_id := p_initiator_resp_appl_id;
    END IF;

    --Begin Bug# 6449697
   OPEN  l_Wf_ItemType;
   FETCH l_Wf_ItemType into l_itemtype;
   CLOSE l_Wf_ItemType;
    -- Create and launch the Workflow process
    WF_ENGINE.CreateProcess(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey,
		process		=> l_workflow_proc );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey,
		aname		=> 'USER_ID',
		avalue		=> l_user_id );

    WF_ENGINE.SetItemAttrText(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey,
		aname		=> 'RESP_ID',
		avalue		=> l_resp_id );

    WF_ENGINE.SetItemAttrText(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey,
		aname		=> 'RESP_APPL_ID',
		avalue		=> l_resp_appl_id );

   IF l_itemtype = 'SERVEREQ' THEN
	    WF_ENGINE.SetItemAttrText(
			itemtype	=> l_itemtype,
			itemkey		=> l_itemkey,
			aname		=> 'INITIATOR_ROLE',
			avalue		=> l_initiator_role );

	    WF_ENGINE.SetItemAttrText(
			itemtype	=> l_itemtype,
			itemkey		=> l_itemkey,
			aname		=> 'WF_ADMINISTRATOR',
			avalue		=> l_administrator );
    END IF;

    wf_engine.setitemowner
      ( itemtype	=> l_itemtype,
	itemkey		=> l_itemkey,
	owner		=> l_initiator_role );

    WF_ENGINE.StartProcess(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey );

--Commented for bug 6449697
 -- Create and launch the Workflow process
    /*WF_ENGINE.CreateProcess(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey,
		process		=> l_workflow_proc );

    WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey,
		aname		=> 'INITIATOR_ROLE',
		avalue		=> l_initiator_role );

    WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey,
		aname		=> 'USER_ID',
		avalue		=> l_user_id ); --5042407

    WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey,
		aname		=> 'RESP_ID',
		avalue		=> l_resp_id ); --5042407

    WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey,
		aname		=> 'RESP_APPL_ID',
		avalue		=> l_resp_appl_id ); --5042407

    WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey,
		aname		=> 'WF_ADMINISTRATOR',
		avalue		=> l_administrator );

    wf_engine.setitemowner
      ( itemtype	=> 'SERVEREQ',
	itemkey		=> l_itemkey,
	owner		=> l_initiator_role );

    WF_ENGINE.StartProcess(
		itemtype	=> 'SERVEREQ',
		itemkey		=> l_itemkey );*/


/****** Fix for Bug # 1348309 & #1349526
 The error is b'cos the create_audit API has been modified
 We will no longer directly update the cs_incidents_all_b table.
 We will be calling the Service request Update API to do the update.
 This API will call the create audit API so we do not have to call this either

    -- Update the workflow process ID of the request

    IF (l_nowait = TRUE) THEN

      UPDATE CS_INCIDENTS_ALL_B
         SET workflow_process_id = l_wf_process_id
       WHERE CURRENT OF l_ServeReq_NW_csr;
      CLOSE l_ServeReq_NW_csr;

    ELSE

      UPDATE CS_INCIDENTS_ALL_B
         SET workflow_process_id = l_wf_process_id
       WHERE incident_number = p_request_number;

--       WHERE CURRENT OF l_ServeReq_csr;
      CLOSE l_ServeReq_csr;

    END IF;

    -- Insert audit record
    l_change_flags_rec.new_workflow := FND_API.G_TRUE;

    CS_ServiceRequest_PVT.Create_Audit_Record (
		p_api_version		=>  2.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		p_commit		=>  FND_API.G_FALSE,
		x_return_status		=>  l_return_status,
		x_msg_count		=>  l_msg_count,
		x_msg_data		=>  l_msg_data,
		p_request_id  	        =>  l_request_id,
                p_change_flags          =>  l_change_flags_rec,
		p_wf_process_name	=>  l_workflow_proc,
		p_wf_process_itemkey	=>  l_itemkey,
		p_user_id		=>  p_initiator_user_id );
******/
--#1349526
--Jul/13/2000
-- Call the SR update API to update cs_incidents_all_b and to insert
-- into audit tables

--dbms_output.put_line('before Update wf_proc_id= ' || l_wf_process_id);
--dbms_output.put_line('before Update l_req_id= ' || l_request_id);

-- initialise

   /**** No longer needed since we are going to explicitly update ****/
   /**** the service request's workflow process id. This therefore ****/
   /**** will not create an audit record for this update. Also,    ****/
   /**** the update API does not handle the p_called_by_workflow   ****/
   /**** anymore. rmanabat  032403				   ****/
    -- CS_ServiceRequest_PVT.initialize_rec(l_service_request_rec);

-- NOtes :
-- We do not pass p-commit to true to the update SR, since
-- we are explicitly doing a commit  here
-- Also, object_version_number will not get incremented in the SR update
-- API when it is being called from workflow as it is
-- conflicting with an update issued from the main SR form
-- The SR update API takes care of this based on the
-- p_called_by_workflow parameter we pass. This should be true.
--Update SR API also has corresponding changes

--Nov/8/2000
--added a new out parameter to this API call,
--X_workflow_process_id since Update_ServiceRequest
--API has been changed

    -- Added mandatory parameter last_update_program_code .11/19/02 rmanabat
    /**** No longer needed . rmanabat 032403 ****/
    --l_service_request_rec.last_update_program_code := 'SUPPORT.WF';

    /**** No longer needed since we are going to explicitly update ****/
    /**** the service request's workflow process id. This therefore ****/
    /**** will not create an audit record for this update. Also,    ****/
    /**** the update API does not handle the p_called_by_workflow   ****/
    /**** anymore. rmanabat  032403				   ****/

    /******************
    CS_ServiceRequest_PVT.Update_ServiceRequest
     ( p_api_version		    => 3.0, -- Changed from 2.0 for 11.5.9
       p_init_msg_list		    => fnd_api.g_false,
       p_commit			    => fnd_api.g_false,
       p_validation_level    => fnd_api.g_valid_level_full,
    x_return_status		    => l_return_status,
    x_msg_count		    => l_msg_count,
    x_msg_data			    => l_msg_data,
    p_request_id		    => l_request_id,
    p_object_version_number  => l_object_version_number,
    p_last_updated_by	    => p_initiator_user_id,
    p_last_update_date	    => sysdate,
    p_service_request_rec    => l_service_request_rec,
    p_notes                  => l_notes,
    p_contacts               => l_contacts,
    p_called_by_workflow	    => FND_API.G_TRUE,
    p_workflow_process_id    => l_wf_process_id,
    x_interaction_id	    => l_interaction_id,
    x_workflow_process_id    => out_wf_process_id
    );

-- dbms_output.put_line('after Update call status' || l_return_status);

    -- Check for possible errors returned by the API
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ***************************/

    /**** Replaced Update API above with explicit update ****/
    /**** rmanabat . 032403 			         ****/

    UPDATE CS_INCIDENTS_ALL_B
    SET workflow_process_id = l_wf_process_id
    WHERE incident_id = l_request_id;


    -- Set up return value
    p_itemkey := l_itemkey;

    /***
    IF (FND_API.To_Boolean( p_commit )  and
        l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT WORK;
    END IF;
    ***/

    IF (FND_API.To_Boolean( p_commit )) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count	 	=> p_msg_count,
			       p_data		=> p_msg_data,
			       p_encoded	=> FND_API.G_FALSE );

  EXCEPTION
    WHEN l_SR_NO_WORKFLOW THEN
      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_SR_NO_WORKFLOW');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN l_SR_CLOSED_STATUS THEN
      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_WF_CLOSED_STATUS');
	FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME||'.'||l_api_name);
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN l_ADMINISTRATOR_NOT_SET THEN
      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_ALL_WF_ADMINISTRATOR');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN l_RESET_ADMINISTRATOR THEN
      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MESSAGE.SET_NAME('CS', 'CS_ALL_RESET_WF_ADMINI');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN l_WORKFLOW_IN_PROGRESS THEN
      /****
      IF (l_ServeReq_NW_csr%ISOPEN) THEN
        CLOSE l_ServeReq_NW_csr;
      ELSIF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;
      ****/
      IF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;

      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_IN_PROGRESS');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('CS', 'CS_SR_WF_RECORD_LOCKED');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN FND_API.G_EXC_ERROR THEN
      /****
      IF (l_ServeReq_NW_csr%ISOPEN) THEN
        CLOSE l_ServeReq_NW_csr;
      ELSIF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;
      ****/
      IF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;

      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
			         p_encoded	=> FND_API.G_FALSE );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /****
      IF (l_ServeReq_NW_csr%ISOPEN) THEN
        CLOSE l_ServeReq_NW_csr;
      ELSIF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;
      ****/
      IF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;

      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
			         p_encoded	=> FND_API.G_FALSE );

    WHEN OTHERS THEN
      /****
      IF (l_ServeReq_NW_csr%ISOPEN) THEN
        CLOSE l_ServeReq_NW_csr;
      ELSIF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;
      ****/
      IF (l_ServeReq_csr%ISOPEN) THEN
        CLOSE l_ServeReq_csr;
      END IF;

      ROLLBACK TO Launch_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
			         p_encoded	=> FND_API.G_FALSE );

  END Launch_Servereq_Workflow;


-- -------------------------------------------------------------------
-- Cancel_Servereq_Workflow
-- -------------------------------------------------------------------

  PROCEDURE Cancel_Servereq_Workflow (
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_commit		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_request_number	  IN VARCHAR2,
		p_wf_process_id		  IN NUMBER,
		p_user_id	  	  IN NUMBER ) IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Cancel_Servereq_Workflow';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_itemkey		VARCHAR2(240);
    l_user_name		VARCHAR2(100);
    l_emp_name		VARCHAR2(240);
    l_aborted_by	VARCHAR2(240);
    l_owner_role	VARCHAR2(100);
    l_notification_id	NUMBER;
    l_dummy		NUMBER := -1;
    l_context		VARCHAR2(100);
    l_NOT_ACTIVE	EXCEPTION;
    l_itemtype VARCHAR2(10); --Bug 6449697

    CURSOR l_itemtype_csr IS --Bug 6449697
      Select item_type
      from cs_incidents_all_b inc, cs_incident_types types, wf_activities wf
      where inc.incident_number= p_request_number
      and types.incident_type_id=inc.incident_type_id
      and wf.name=types.workflow;

  BEGIN
    -- API savepoint
    SAVEPOINT Cancel_Workflow_PUB;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- First construct the item key
    -- If we ever change the format of the itemkey, the following code
    -- must be updated
    --
    l_itemkey := p_request_number||'-'||to_char(p_wf_process_id);

    --
    -- Make sure that the item is still active
    --
    IF (CS_Workflow_PKG.Is_Servereq_Item_Active (
		p_request_number	=>  p_request_number,
		p_wf_process_id 	=>  p_wf_process_id ) = 'N') THEN
      raise l_NOT_ACTIVE;
    END IF;

    --
    -- Get the employee name of the user who is aborting the process
    -- If we can't get that information, just use the FND username
    --
    SELECT fnd.user_name, emp.full_name
      INTO l_user_name, l_emp_name
      FROM fnd_user fnd, per_people_x emp
     WHERE fnd.user_id = p_user_id
       AND fnd.employee_id = emp.person_id (+);

    IF (l_emp_name IS NOT NULL) THEN
      l_aborted_by := l_emp_name;
    ELSE
      l_aborted_by := l_user_name;
    END IF;
--Bug 6449697
    OPEN l_itemtype_csr;
    FETCH l_itemtype_csr into l_itemtype;
    CLOSE l_itemtype_csr;

    IF l_itemtype = 'SERVEREQ' THEN ----Bug 6449697
	    -- Call Workflow API to abort the process
	    WF_ENGINE.AbortProcess(
				itemtype	=>  'SERVEREQ',
				itemkey		=>  l_itemkey );

	    -- Notify the current owner that the process has been aborted
	    l_owner_role := WF_ENGINE.GetItemAttrText(
				itemtype	=>  'SERVEREQ',
				itemkey		=>  l_itemkey,
				aname		=>  'OWNER_ROLE' );

	    -- Set up the context information for the callback function
	    l_context := 'SERVEREQ'||':'||l_itemkey||':'||to_char(l_dummy);

	    IF (l_owner_role IS NOT NULL) THEN

	      -- Note that we're using Workflow engine's callback function
	      l_notification_id := WF_Notification.Send(
				role		=>  l_owner_role,
				msg_type	=>  'SERVEREQ',
				msg_name	=>  'ABORT_MESG',
				callback	=>  'WF_ENGINE.CB',
				context		=>  l_context );

	      WF_Notification.SetAttrText(
				nid		=>  l_notification_id,
				aname		=>  'ABORT_USER',
				avalue		=>  l_aborted_by );
	    END IF;
    --Bug 6449697
    ELSIF l_itemtype = 'EAMSRAPR' THEN
             WF_ENGINE.AbortProcess(
				itemtype	=>  'EAMSRAPR',
				itemkey		=>  l_itemkey );
    END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count 	=> p_msg_count,
			       p_data	=> p_msg_data,
			       p_encoded	=> FND_API.G_FALSE );

  EXCEPTION
    WHEN l_NOT_ACTIVE THEN
      ROLLBACK TO Cancel_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_SR_WORKFLOW_NOT_ACTIVE');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

    WHEN OTHERS THEN
      ROLLBACK TO Cancel_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data,
				 p_encoded	=> FND_API.G_FALSE );

  END Cancel_Servereq_Workflow;


-- --------------------------------------------------------------------------------------
-- Decode_Servereq_Itemkey
--
--   A Service Request itemkey has the following format:
--
--     ' <Service Request Number>-<Workflow Process ID>'
--
--   For example, service request #100 with Workflow process ID of 200
--   has the following itemkey:
--
--     '100-200'
--
--  Date        Name       Desc
--  ----------  ---------  ------------------------------------------------------------
--  26-OCT-2005 aneemuch   Changed l_pos := INSTR(l_itemkey, '-') to
--			   l_dash_pos := instr(p_itemkey, '-',-1,1), per bug 4007088.
--
-- --------------------------------------------------------------------------------------

  PROCEDURE Decode_Servereq_Itemkey(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_itemkey		  IN VARCHAR2,
		p_request_number	 OUT NOCOPY VARCHAR2,
		p_wf_process_id		 OUT NOCOPY NUMBER ) is

    l_api_name	  CONSTANT VARCHAR2(30) := 'Decode_Servereq_Itemkey';
    l_api_version CONSTANT NUMBER       := 1.0;

    l_dash_pos		NUMBER;
    l_INVALID_ITEMKEY	EXCEPTION;

  BEGIN
    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return value
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --l_dash_pos := instr(p_itemkey, '-');
    l_dash_pos := instr(p_itemkey, '-',-1,1); -- Bug # 4007088

    IF (l_dash_pos = 0) THEN
      raise l_INVALID_ITEMKEY;
    END IF;

    p_request_number := substr(p_itemkey, 1, l_dash_pos - 1);
    p_wf_process_id := to_number(substr(p_itemkey,
					l_dash_pos + 1,
					length(p_itemkey) - l_dash_pos));

    FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			       p_data	=> p_msg_data );

  EXCEPTION
    WHEN l_INVALID_ITEMKEY THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_INVALID_ARGUMENT');
	FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME||'.'||l_api_name);
	FND_MESSAGE.SET_TOKEN('VALUE', p_itemkey);
	FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_ITEMKEY');
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

  END Decode_Servereq_Itemkey;


-- -------------------------------------------------------------------
-- Encode_Servereq_Itemkey
--
--   A Service Request itemkey has the following format:
--
--     ' <Service Request Number>-<Workflow Process ID>'
--
--   For example, service request #100 with Workflow process ID of 200
--   has the following itemkey:
--
--     '100-200'
--
-- -------------------------------------------------------------------

  PROCEDURE Encode_Servereq_Itemkey(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_request_number	  IN VARCHAR2,
		p_wf_process_id		  IN NUMBER,
		p_itemkey		 OUT NOCOPY VARCHAR2 ) IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Encode_Servereq_Itemkey';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return value
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate arguments
    If (p_request_number IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_request_number' );
      raise FND_API.G_EXC_ERROR;
    ELSIF (p_wf_process_id IS NULL) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  l_api_name_full,
		p_token_np	=>  'p_wf_process_id' );
      raise FND_API.G_EXC_ERROR;
    END IF;

    p_itemkey := p_request_number||'-'||to_char(p_wf_process_id);

    FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			       p_data	=> p_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

  END Encode_Servereq_Itemkey;


-- -------------------------------------------------------------------
-- Get_Employee_Role
-- -------------------------------------------------------------------

  PROCEDURE Get_Employee_Role (
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_employee_id  		  IN NUMBER    ,
		p_emp_last_name		  IN VARCHAR2  ,
		p_emp_first_name	  IN VARCHAR2  ,
		p_role_name		 OUT NOCOPY VARCHAR2,
		p_role_display_name	 OUT NOCOPY VARCHAR2 ) IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Get_Employee_Role';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_employee_id	NUMBER;

  BEGIN
    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the parameters and get the employee ID
    Get_Employee_ID(
		p_api_version		=>  1.0,
	        p_init_msg_list		=>  FND_API.G_FALSE,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_api_name		=>  G_PKG_NAME||'.'||l_api_name,
		p_employee_id		=>  p_employee_id,
		p_emp_last_name	 	=>  p_emp_last_name,
		p_emp_first_name	=>  p_emp_first_name,
		p_employee_id_out	=>  l_employee_id );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call Workflow API to get the role
    -- If there is more than one role for this employee, the API will
    -- return the first one fetched.  If no Workflow role exists for
    -- the employee, out variables will be NULL
    WF_DIRECTORY.GetRoleName(
		p_orig_system 	  => 'PER',
		p_orig_system_id  => l_employee_id,
		p_name		  => p_role_name,
		p_display_name    => p_role_display_name );

    FND_MSG_PUB.Count_And_Get( p_count 	=> p_msg_count,
			       p_data	=> p_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count  => p_msg_count,
			         p_data   => p_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count  => p_msg_count,
			         p_data	  => p_msg_data );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

  END Get_Employee_Role;


-- -------------------------------------------------------------------
-- Get_Emp_Supervisor
-- -------------------------------------------------------------------

  PROCEDURE Get_Emp_Supervisor(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_employee_id		  IN NUMBER    ,
		p_emp_last_name		  IN VARCHAR2  ,
		p_emp_first_name	  IN VARCHAR2  ,
		p_supervisor_emp_id 	 OUT NOCOPY NUMBER,
		p_supervisor_role	 OUT NOCOPY VARCHAR2,
		p_supervisor_name 	 OUT NOCOPY VARCHAR2 ) IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Get_Emp_Supervisor';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_return_status	VARCHAR2(1);
    l_supervisor_id	NUMBER;
    l_employee_id	NUMBER;

    --
    -- Following cursor declaration is taken from HR_OFFER_CUSTOM package
    --
    CURSOR l_supervisor_csr( l_effective_date IN DATE,
			     l_in_person_id   IN NUMBER) IS
	SELECT  ppf.person_id
    	  FROM  per_assignments_f paf,
	   	per_people_f      ppf
	 WHERE  paf.person_id	      = l_in_person_id
	   AND  paf.primary_flag      = 'Y'
	   AND  l_effective_date BETWEEN paf.effective_start_date
    				     AND paf.effective_end_date
	   AND  ppf.person_id	      = paf.supervisor_id
	   AND  ppf.current_employee_flag = 'Y'
	   AND  l_effective_date BETWEEN ppf.effective_start_date
				     AND ppf.effective_end_date;

  BEGIN

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return values
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_supervisor_role   := NULL;
    p_supervisor_name   := NULL;

    -- Validate the parameters and get the employee ID
    Get_Employee_ID(
		p_api_version		=>  1.0,
	        p_init_msg_list		=>  FND_API.G_FALSE,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_api_name		=>  G_PKG_NAME||'.'||l_api_name,
		p_employee_id		=>  p_employee_id,
		p_emp_last_name	 	=>  p_emp_last_name,
		p_emp_first_name	=>  p_emp_first_name,
		p_employee_id_out	=>  l_employee_id );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_supervisor_id := NULL;

    OPEN  l_supervisor_csr(TRUNC(sysdate), l_employee_id);
    FETCH l_supervisor_csr INTO l_supervisor_id;
    CLOSE l_supervisor_csr;

    p_supervisor_emp_id := l_supervisor_id;

    IF (l_supervisor_id IS NOT NULL) THEN

      CS_WORKFLOW_PUB.Get_Employee_Role (
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id  		=>  l_supervisor_id,
		p_role_name		=>  p_supervisor_role,
		p_role_display_name	=>  p_supervisor_name );

      -- Check for possible errors returned by the API
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        raise FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

    FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			       p_data	=> p_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

  END Get_Emp_Supervisor;


-- -----------------------------------------------------------------------
-- Get_Emp_Fnd_User_ID
-- -----------------------------------------------------------------------

  PROCEDURE Get_Emp_Fnd_User_ID(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_employee_id	 	  IN NUMBER    ,
		p_emp_last_name		  IN VARCHAR2  ,
		p_emp_first_name	  IN VARCHAR2  ,
		p_fnd_user_id 		 OUT NOCOPY NUMBER ) IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Get_Emp_Fnd_User_ID';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_return_status	VARCHAR2(1);
    l_employee_id	NUMBER;

    CURSOR l_emp_csr IS
	SELECT user_id
	  FROM fnd_user
	 WHERE employee_id = l_employee_id;

  BEGIN

    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return value
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the parameters and get the employee ID
    Get_Employee_ID(
		p_api_version		=>  1.0,
	        p_init_msg_list		=>  FND_API.G_FALSE,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_api_name		=>  G_PKG_NAME||'.'||l_api_name,
		p_employee_id		=>  p_employee_id,
		p_emp_last_name	 	=>  p_emp_last_name,
		p_emp_first_name	=>  p_emp_first_name,
		p_employee_id_out	=>  l_employee_id );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Bug 654417: TOO_MANY_ROWS exception when SELECT INTO statement
    -- returns more than one row
    -- The FETCH statement raises neither NO_DATA_FOUND nor TOO_MANY_ROWS
    OPEN l_emp_csr;
    FETCH l_emp_csr INTO p_fnd_user_id;
    CLOSE l_emp_csr;

    FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			       p_data	=> p_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

  END Get_Emp_Fnd_User_ID;


----------------------------------------------------------------------
-- Launch_Action_Workflow
--   This procedure launches a workflow process for the given service
--   request action. It selects the workflow process to run base on
--   the action type, and it initializes two item attributes
--   INITIATOR_ROLE and WF_ADMINISTRATOR.
----------------------------------------------------------------------

/*PROCEDURE Launch_Action_Workflow
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
  p_return_status		OUT	VARCHAR2,
  p_msg_count			OUT	NUMBER,
  p_msg_data			OUT	VARCHAR2,
  p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_initiator_user_id		IN	NUMBER   := NULL,
  p_initiator_resp_id		IN	NUMBER   := NULL,
  p_initiator_resp_appl_id	IN	NUMBER   := NULL,
  p_launched_by_dispatch	IN	VARCHAR2 := FND_API.G_FALSE,
  p_nowait			IN	VARCHAR2 := FND_API.G_FALSE,
  p_itemkey			OUT	VARCHAR2
)
IS
  l_api_name	       CONSTANT VARCHAR2(30) := 'Launch_Action_Workflow';
  l_api_version	       CONSTANT	NUMBER       := 1.0;
  l_itemtype	       CONSTANT	VARCHAR2(30) := 'SRACTION';

  l_nowait			BOOLEAN      := FALSE;
  l_administrator		VARCHAR2(100);
  l_dummy			VARCHAR2(240);
  l_request_action_id		NUMBER;
  l_request_id			NUMBER;
  l_wf_process_id		NUMBER;
  l_workflow_proc		VARCHAR2(30);
  l_itemkey			VARCHAR2(240);
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);
  l_initiator_role		VARCHAR2(100);
  l_action_audit_id		NUMBER;

  l_exc_administrator_not_set	EXCEPTION;
  l_exc_reset_administrator	EXCEPTION;
  l_exc_workflow_in_progress	EXCEPTION;
  l_exc_sr_no_workflow		EXCEPTION;

  CURSOR l_action_nw_csr IS
    SELECT incident_action_id, incident_id, workflow_process_id
    FROM   cs_incident_actions
    WHERE  incident_id = p_request_id
    AND    action_num = p_action_number
    FOR UPDATE OF workflow_process_id NOWAIT;

  CURSOR l_action_csr IS
    SELECT incident_action_id, incident_id, workflow_process_id
    FROM   cs_incident_actions
    WHERE  incident_id = p_request_id
    AND    action_num = p_action_number
    FOR UPDATE OF workflow_process_id;

  CURSOR l_wf_proc_id_csr IS
    SELECT cs_action_wf_proc_id_s.nextval
    FROM   dual;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Launch_Action_Workflow_PUB;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Set nowait option
  IF FND_API.To_Boolean( p_nowait ) THEN
    l_nowait := TRUE;
  END IF;

  -- Get the Workflow Administrator Role
  l_administrator := FND_PROFILE.Value('CS_WF_ADMINISTRATOR');

  --
  -- The Service Dispatch process activity is associated with the service
  -- request error process, which requires the customer to set up the
  -- 'Service: Workflow Administrator' profile as the performer of the service
  -- request error notification.
  --
  IF (l_administrator IS NULL) THEN
    RAISE l_exc_administrator_not_set;
  ELSE
    BEGIN
      SELECT 'x' INTO l_dummy
      FROM   WF_ROLES
      WHERE  name = l_administrator;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	-- Invalid administrator role
	RAISE l_exc_reset_administrator;
      WHEN TOO_MANY_ROWS THEN
	-- Okay here
	NULL;
    END;
  END IF;

  -- Get the last workflow process ID of this request and lock the record
  IF (l_nowait = TRUE) THEN
    OPEN l_action_nw_csr;
    FETCH l_action_nw_csr INTO l_request_action_id, l_request_id, l_wf_process_id;
  ELSE
    OPEN l_action_csr;
    FETCH l_action_csr INTO l_request_action_id, l_request_id, l_wf_process_id;
  END IF;

  -- Verify that the workflow is not active
  IF (l_wf_process_id IS NOT NULL) THEN
    IF (CS_Workflow_PKG.Is_Action_Item_Active
	  ( p_request_id	=> p_request_id,
	    p_action_number	=> p_action_number,
	    p_wf_process_id	=> l_wf_process_id ) = 'Y') THEN
      RAISE l_exc_workflow_in_progress;
    END IF;
  END IF;

  -- Get the workflow process name for this request from the request type
  SELECT type.workflow INTO l_workflow_proc
  FROM   cs_incident_actions action, cs_incident_types type
  WHERE  action.incident_id = p_request_id
  AND    action.action_num = p_action_number
  AND    action.action_type_id = type.incident_type_id;

  IF (l_workflow_proc IS NULL) THEN
    RAISE l_exc_sr_no_workflow;
  END IF;

  -- Get the new workflow process ID
  OPEN  l_wf_proc_id_csr;
  FETCH l_wf_proc_id_csr INTO l_wf_process_id;
  CLOSE l_wf_proc_id_csr;

  -- Construct the unique item key
  l_itemkey := p_request_id || '-' || p_action_number || '-' || l_wf_process_id;

  -- Get the process initiator's workflow role name
  IF (p_initiator_user_id IS NOT NULL) THEN
     get_fnd_user_role
       ( p_fnd_user_id		=> p_initiator_user_id,
	 x_role_name		=> l_initiator_role,
	 x_role_display_name	=> l_dummy );
  END IF;

  -- Create and launch the Workflow process
  WF_ENGINE.CreateProcess
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      process	=> l_workflow_proc
    );

  WF_ENGINE.SetItemAttrText
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      aname	=> 'INITIATOR_ROLE',
      avalue	=> l_initiator_role
    );

  WF_ENGINE.SetItemAttrText
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      aname	=> 'USER_ID',
      avalue	=> p_initiator_user_id
    );

  WF_ENGINE.SetItemAttrText
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      aname	=> 'RESP_ID',
      avalue	=> p_initiator_resp_id
    );

  WF_ENGINE.SetItemAttrText
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      aname	=> 'RESP_APPL_ID',
      avalue	=> p_initiator_resp_appl_id
    );

  WF_ENGINE.SetItemAttrText
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      aname	=> 'WF_ADMINISTRATOR',
      avalue	=> l_administrator
    );

  WF_ENGINE.SetItemAttrText
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      aname	=> 'LAUNCHED_BY_DISPATCH',
      avalue	=> p_launched_by_dispatch
    );

  wf_engine.setitemowner
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey,
      owner	=> l_initiator_role );

  WF_ENGINE.StartProcess
    ( itemtype	=> l_itemtype,
      itemkey	=> l_itemkey
    );

  -- Update the workflow process ID of the request
  IF (l_nowait = TRUE) THEN
    UPDATE cs_incident_actions
    SET    workflow_process_id = l_wf_process_id
    WHERE CURRENT OF l_action_nw_csr;

    CLOSE l_action_nw_csr;
  ELSE
    UPDATE cs_incident_actions
    SET	   workflow_process_id = l_wf_process_id
    WHERE CURRENT OF l_action_csr;

    CLOSE l_action_csr;
  END IF;

  -- Insert audit record
  SELECT cs_incident_action_audit_s.NEXTVAL INTO l_action_audit_id FROM dual;

  INSERT INTO cs_incident_action_audit
    ( incident_action_audit_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      incident_action_id,
      incident_id,
      new_workflow_flag,
      workflow_process_name,
      workflow_process_itemkey
    )
  VALUES
    ( l_action_audit_id,	-- INCIDENT_ACTION_AUDIT_ID
      SYSDATE,			-- LAST_UPDATE_DATE
      p_initiator_user_id,	-- LAST_UPDATED_BY
      SYSDATE,			-- CREATION_DATE
      p_initiator_user_id,	-- CREATED_BY
      l_request_action_id,	-- INCIDENT_ACTION_ID
      l_request_id,		-- INCIDENT_ID
      'Y',		--	 NEW_WORKFLOW_FLAG
      l_workflow_proc,	--	 WORKFLOW_PROCESS_NAME
      l_itemkey	--		 WORKFLOW_PROCESS_ITEMKEY
    );

  -- Set up return value
  p_itemkey := l_itemkey;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
    ( p_count	 	=> p_msg_count,
      p_data		=> p_msg_data,
      p_encoded	=> FND_API.G_FALSE
    );

EXCEPTION
  WHEN l_exc_administrator_not_set THEN
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_ALL_WF_ADMINISTRATOR');
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN l_exc_reset_administrator THEN
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_ALL_RESET_WF_ADMINI');
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN l_exc_workflow_in_progress THEN
    IF (l_action_nw_csr%ISOPEN) THEN
      CLOSE l_action_nw_csr;
    ELSIF (l_action_csr%ISOPEN) THEN
      CLOSE l_action_csr;
    END IF;
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_ACT_WORKFLOW_IN_PROGRESS');
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN l_exc_sr_no_workflow THEN
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_ACT_NO_WORKFLOW');
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_ACT_WF_RECORD_LOCKED');
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN FND_API.G_EXC_ERROR THEN
    IF (l_action_nw_csr%ISOPEN) THEN
      CLOSE l_action_nw_csr;
    ELSIF (l_action_csr%ISOPEN) THEN
      CLOSE l_action_csr;
    END IF;
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_action_nw_csr%ISOPEN) THEN
      CLOSE l_action_nw_csr;
    ELSIF (l_action_csr%ISOPEN) THEN
      CLOSE l_action_csr;
    END IF;
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN OTHERS THEN
    IF (l_action_nw_csr%ISOPEN) THEN
      CLOSE l_action_nw_csr;
    ELSIF (l_action_csr%ISOPEN) THEN
      CLOSE l_action_csr;
    END IF;
    ROLLBACK TO Launch_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME,
	  l_api_name
	);
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );

END Launch_Action_Workflow;*/


----------------------------------------------------------------------
-- Cancel_Action_Workflow
----------------------------------------------------------------------

PROCEDURE Cancel_Action_Workflow
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
  p_return_status		OUT	NOCOPY VARCHAR2,
  p_msg_count			OUT	NOCOPY NUMBER,
  p_msg_data			OUT	NOCOPY VARCHAR2,
  p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_wf_process_id		IN	NUMBER,
  p_abort_user_id		IN	NUMBER,
  p_launched_by_dispatch	OUT	NOCOPY VARCHAR2
)
IS
  l_api_name	       CONSTANT VARCHAR2(30) := 'Cancel_Action_Workflow';
  l_api_version	       CONSTANT	NUMBER       := 1.0;
  l_itemtype	       CONSTANT	VARCHAR2(30) := 'SRACTION';
  l_activityid	       CONSTANT	NUMBER       := -1;

  l_itemkey			VARCHAR2(240);
  l_user_name			VARCHAR2(100);
  l_emp_name			VARCHAR2(240);
  l_aborted_by			VARCHAR2(240);
  l_context			VARCHAR2(252);
  l_assignee_role		VARCHAR2(100);
  l_notification_id		NUMBER;
  l_dispatch_role		VARCHAR2(100);
  l_dummy			VARCHAR2(1);

  l_exc_not_active		EXCEPTION;

  CURSOR l_dispatch_csr IS
    SELECT 'x'
    FROM   wf_roles
    WHERE  name = l_dispatch_role;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Cancel_Action_Workflow_PUB;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- First construct the item key
  -- If we ever change the format of the itemkey, the following code
  -- must be updated
  --
  l_itemkey := p_request_id || '-' || p_action_number || '-' || p_wf_process_id;

  --
  -- Make sure that the item is still active
  --
  IF (CS_Workflow_PKG.Is_Action_Item_Active
	( p_request_id		=> p_request_id,
	  p_action_number	=> p_action_number,
	  p_wf_process_id 	=> p_wf_process_id ) = 'N') THEN
    RAISE l_exc_not_active;
  END IF;

  --
  -- Get the employee name of the user who is aborting the process
  -- If we can't get that information, just use the FND username
  --
  SELECT fnd.user_name, emp.full_name
  INTO   l_user_name, l_emp_name
  FROM   fnd_user fnd, per_people_x emp
  WHERE  fnd.user_id = p_abort_user_id
  AND    fnd.employee_id = emp.person_id (+);

  IF (l_emp_name IS NOT NULL) THEN
    l_aborted_by := l_emp_name;
  ELSE
    l_aborted_by := l_user_name;
  END IF;

  -- Call Workflow API to abort the process
  WF_ENGINE.AbortProcess
    ( itemtype	=>  l_itemtype,
      itemkey	=>  l_itemkey );

  -- Set up the context information for the callback function
  -- The format is <itemtype>:<itemkey>:<activityid>
  l_context := l_itemtype || ':' || l_itemkey || ':' || l_activityid;

  -- Notify the current owner that the process has been aborted
  -- Note that we're using Workflow engine's callback function
  l_assignee_role := WF_ENGINE.GetItemAttrText
		       ( itemtype	=> l_itemtype,
			 itemkey	=> l_itemkey,
			 aname		=> 'ASSIGNEE_ROLE'
		       );
  IF (l_assignee_role IS NOT NULL) THEN
    l_notification_id := WF_Notification.Send
			   ( role	=> l_assignee_role,
			     msg_type	=> l_itemtype,
			     msg_name	=> 'ABORT_MSG',
			     callback	=> 'WF_ENGINE.CB',
			     context	=> l_context
			   );
    WF_Notification.SetAttrText
      (	nid	=>  l_notification_id,
	aname	=>  'ABORT_USER',
	avalue	=>  l_aborted_by
      );
  END IF;

  -- Notify the dispatcher that the process has been aborted
  l_dispatch_role := WF_ENGINE.GetItemAttrText
			 ( itemtype	=> l_itemtype,
			   itemkey	=> l_itemkey,
			   aname	=> 'DISPATCHER_ROLE'
			 );
  IF (l_dispatch_role IS NOT NULL) THEN
    --
    -- Verify that the dispatch role exists in the workflow directory
    -- before sending the abort notification
    --
    OPEN l_dispatch_csr;
    FETCH l_dispatch_csr INTO l_dummy;
    IF (l_dispatch_csr%NOTFOUND) THEN
      -- Okay here; probably some other error occurred so the administrator
      -- wants to abort the process
      NULL;
    ELSE
      l_notification_id := WF_Notification.Send
			     ( role	=> l_dispatch_role,
			       msg_type	=> l_itemtype,
			       msg_name	=> 'ABORT_MSG',
			       callback	=> 'WF_ENGINE.CB',
			       context	=> l_context
			     );
      WF_Notification.SetAttrText
	( nid		=>  l_notification_id,
	  aname		=>  'ABORT_USER',
	  avalue	=>  l_aborted_by
	);
    END IF;
  END IF;

  p_launched_by_dispatch := WF_ENGINE.GetItemAttrText
			      ( itemtype	=> l_itemtype,
				itemkey		=> l_itemkey,
				aname		=> 'LAUNCHED_BY_DISPATCH'
			      );

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
    ( p_count	=> p_msg_count,
      p_data	=> p_msg_data,
      p_encoded	=> FND_API.G_FALSE
    );

EXCEPTION
  WHEN l_exc_not_active THEN
    ROLLBACK TO Cancel_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_NOT_ACTIVE');
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );
  WHEN OTHERS THEN
    ROLLBACK TO Cancel_Action_Workflow_PUB;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME,
	  l_api_name
	);
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count		=> p_msg_count,
	p_data		=> p_msg_data,
	p_encoded	=> FND_API.G_FALSE
      );

END Cancel_Action_Workflow;


--------------------------------------------------------------------------
-- Decode_Action_Itemkey
--
--   A Service Request Action itemkey has the following format:
--
--     '<Service Request ID>-<Action Number>-<Workflow Process ID>'
--
--------------------------------------------------------------------------

PROCEDURE Decode_Action_Itemkey
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_return_status	OUT	NOCOPY VARCHAR2,
  p_msg_count		OUT	NOCOPY NUMBER,
  p_msg_data		OUT	NOCOPY VARCHAR2,
  p_itemkey		IN	VARCHAR2,
  p_request_id		OUT	NOCOPY NUMBER,
  p_action_number	OUT	NOCOPY NUMBER,
  p_wf_process_id	OUT	NOCOPY NUMBER
)
IS
  l_api_name	       CONSTANT	VARCHAR2(30) := 'Decode_Action_Itemkey';
  l_api_version	       CONSTANT	NUMBER       := 1.0;

  l_dash_pos1			NUMBER;
  l_dash_pos2			NUMBER;

  l_exc_invalid_itemkey		EXCEPTION;

BEGIN
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_dash_pos1 := INSTR(p_itemkey, '-');
  l_dash_pos2 := INSTR(p_itemkey, '-', l_dash_pos1+1);
  IF ((l_dash_pos1 = 0) OR (l_dash_pos2 = 0)) THEN
    RAISE l_exc_invalid_itemkey;
  END IF;

  p_request_id := SUBSTR(p_itemkey, 1, l_dash_pos1-1);
  p_action_number := SUBSTR(p_itemkey, l_dash_pos1+1, l_dash_pos2-l_dash_pos1-1);
  p_wf_process_id := SUBSTR(p_itemkey, l_dash_pos2+1);

  FND_MSG_PUB.Count_And_Get
    ( p_count	=> p_msg_count,
      p_data	=> p_msg_data
    );

EXCEPTION
  WHEN l_exc_invalid_itemkey THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
      (	p_token_an	=> G_PKG_NAME||'.'||l_api_name,
	p_token_v	=> p_itemkey,
	p_token_p	=> 'p_itemkey'
      );
    FND_MSG_PUB.Count_And_Get
      (	p_count	=> p_msg_count,
	p_data	=> p_msg_data
      );
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (	p_count	=> p_msg_count,
	p_data	=> p_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (	p_count	=> p_msg_count,
	p_data	=> p_msg_data
      );
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME,
	  l_api_name
	);
    END IF;
    FND_MSG_PUB.Count_And_Get
      (	p_count	=> p_msg_count,
	p_data	=> p_msg_data
      );

END Decode_Action_Itemkey;

/****************************************************************************
			  Local Procedure Bodies
 ****************************************************************************/

-- -------------------------------------------------------------------
-- LOCAL: Get_Employee_ID
-- -------------------------------------------------------------------

  PROCEDURE Get_Employee_ID (
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2   ,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_api_name		  IN VARCHAR2,
		p_employee_id	          IN NUMBER     ,
		p_emp_last_name	 	  IN VARCHAR2   ,
		p_emp_first_name	  IN VARCHAR2   ,
		p_employee_id_out	 OUT NOCOPY NUMBER ) IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Get_Employee_ID';
    l_api_version CONSTANT NUMBER       := 1.0;

    l_dummy		VARCHAR2(1);

    l_INVALID_EMP_NAME  EXCEPTION;
    l_DUPLICATE_VALUE	EXCEPTION;

  BEGIN
    -- Check version number
    IF NOT FND_API.Compatible_API_Call( l_api_version,
				        p_api_version,
				        l_api_name,
				        G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Verify arguments
    IF (p_employee_id IS NULL) THEN
      IF  (p_emp_last_name IS NULL) AND
          (p_emp_first_name IS NULL) THEN
	CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(
		p_token_an	=>  p_api_name,
		p_token_np	=>  'p_employee_id' );
        raise FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      IF (p_emp_last_name IS NOT NULL) THEN
        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  p_api_name,
		p_token_ip	=>  'p_emp_last_name');
      END IF;

      IF (p_emp_first_name IS NOT NULL) THEN
        CS_ServiceRequest_UTIL.Add_Param_Ignored_Msg(
		p_token_an	=>  p_api_name,
		p_token_ip	=>  'p_emp_first_name');
      END IF;
    END IF;

    -- Get the employee ID from the name
    IF (p_employee_id IS NULL) THEN

      BEGIN
        IF (p_emp_last_name IS NULL) THEN

	  SELECT person_id INTO p_employee_id_out
	    FROM per_people_x
	   WHERE first_name = p_emp_first_name
	     AND employee_number IS NOT NULL;

        ELSIF (p_emp_first_name IS NULL) THEN

	  SELECT person_id INTO p_employee_id_out
	    FROM per_people_x
	   WHERE last_name = p_emp_last_name
	     AND employee_number IS NOT NULL;

        ELSE

	  SELECT person_id INTO p_employee_id_out
	    FROM per_people_x
	   WHERE last_name = p_emp_last_name
	     AND first_name = p_emp_first_name
	     AND employee_number IS NOT NULL;

        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  raise l_INVALID_EMP_NAME;

        WHEN TOO_MANY_ROWS THEN
	  raise l_DUPLICATE_VALUE;
      END;

    ELSE

      BEGIN

	SELECT 'x' INTO l_dummy
	  FROM per_people_x
	 WHERE person_id = p_employee_id;

        p_employee_id_out := p_employee_id;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
			p_token_an	=>  P_api_name,
			p_token_v	=>  to_char(p_employee_id),
			p_token_p	=>  'p_employee_id' );
          raise FND_API.G_EXC_ERROR;
      END;

    END IF;

    FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			       p_data	=> p_msg_data );

  EXCEPTION
    WHEN l_INVALID_EMP_NAME THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_INVALID_EMP_NAME');
 	FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
	FND_MESSAGE.SET_TOKEN('FIRST_NAME', p_emp_first_name);
	FND_MESSAGE.SET_TOKEN('LAST_NAME', p_emp_last_name);
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN l_DUPLICATE_VALUE THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_DUPLICATE_EMPLOYEE');
	FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
	FND_MESSAGE.SET_TOKEN('FIRST_NAME', p_emp_first_name);
	FND_MESSAGE.SET_TOKEN('LAST_NAME', p_emp_last_name);
	FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
			         l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count	=> p_msg_count,
			         p_data		=> p_msg_data );

  END Get_Employee_ID;

------------------------------------------------------------------------------
--  Procedure	: Get_Fnd_User_Role
------------------------------------------------------------------------------

PROCEDURE Get_Fnd_User_Role
  ( p_fnd_user_id	IN	NUMBER,
    x_role_name		OUT	NOCOPY VARCHAR2,
    x_role_display_name	OUT	NOCOPY VARCHAR2 )
  IS
     l_employee_id	NUMBER;
BEGIN
   -- map the FND user to employee ID
   SELECT employee_id INTO l_employee_id
     FROM fnd_user
     WHERE user_id = p_fnd_user_id;

   IF (l_employee_id IS NOT NULL) THEN
      wf_directory.getrolename
	( p_orig_system		=> 'PER',
	  p_orig_system_id	=> l_employee_id,
	  p_name		=> x_role_name,
	  p_display_name	=> x_role_display_name );
    ELSE
      wf_directory.getrolename
	( p_orig_system		=> 'FND_USR',
	  p_orig_system_id	=> p_fnd_user_id,
	  p_name		=> x_role_name,
	  p_display_name	=> x_role_display_name );
   END IF;
END Get_Fnd_User_Role;

END CS_Workflow_PUB;

/
