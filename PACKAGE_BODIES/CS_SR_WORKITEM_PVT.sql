--------------------------------------------------------
--  DDL for Package Body CS_SR_WORKITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_WORKITEM_PVT" AS
/* $Header: csvsrwib.pls 120.6 2006/03/08 17:36:02 spusegao ship $ */


  PROCEDURE Create_Workitem(
		p_api_version		IN NUMBER,
		p_init_msg_list		IN VARCHAR2	DEFAULT fnd_api.g_false,
		p_commit		IN VARCHAR2	DEFAULT fnd_api.g_false,
		p_incident_id		IN NUMBER,
		p_incident_number	IN VARCHAR2,
		p_sr_rec	IN CS_ServiceRequest_PVT.service_request_rec_type,
  		--p_owner_group_id	IN NUMBER	DEFAULT NULL,
		--p_owner_group_type	IN VARCHAR2	DEFAULT NULL,
		--p_individual_owner_id	IN NUMBER	DEFAULT NULL,
		--p_individual_owner_type	IN VARCHAR2	DEFAULT NULL,
		--p_incident_status_id	IN NUMBER,
		--p_incident_severity_id	IN NUMBER,
		--p_customer_id		IN NUMBER,
		--p_summary		IN VARCHAR2,
		--p_responded_by_date	IN DATE	DEFAULT NULL,
		--p_obligation_date	IN DATE	DEFAULT NULL,
		--p_expected_resolution_date	IN DATE	DEFAULT NULL,
		p_user_id		IN NUMBER,	-- Required
		p_resp_appl_id		IN NUMBER,	-- Required
		p_login_id		IN NUMBER DEFAULT NULL,
		x_work_item_id		OUT	NOCOPY NUMBER,
		x_return_status		OUT	NOCOPY VARCHAR2,
		x_msg_count		OUT	NOCOPY NUMBER,
		x_msg_data		OUT	NOCOPY VARCHAR2) IS

      l_priority_code		VARCHAR2(30);
      l_due_date		DATE;
      l_return_status		VARCHAR2(1);
      l_work_item_id		NUMBER;
      l_wi_status		VARCHAR2(30);
      l_close_flag		VARCHAR2(1);
      l_API_ERROR		EXCEPTION;

      l_owner_group_id		NUMBER;
      l_owner_group_type	cs_incidents_all_b.GROUP_TYPE%TYPE;
      l_individual_owner_id	NUMBER;
      l_individual_owner_type	cs_incidents_all_b.RESOURCE_TYPE%TYPE;
      l_responded_by_date	DATE;
      l_obligation_date		DATE;
      l_expected_resolution_date	DATE;
      l_login_id		NUMBER;
      l_resp_appl_id		NUMBER := p_resp_appl_id;
      l_user_id			NUMBER := p_user_id;
      l_sr_activation_status    VARCHAR2(3) := 'N';
      l_change_wi_flag          VARCHAR2(3);

      CURSOR sel_status_csr IS
        SELECT  decode(on_hold_flag, 'Y', 'SLEEP', 'OPEN') wi_status,
                nvl(close_flag,'N')
        FROM cs_incident_statuses_b
        WHERE incident_status_id = p_sr_rec.status_id;

      cursor sel_sr_wi_csr is
        select work_item_id
        from ieu_uwqm_items
        where WORKITEM_OBJ_CODE = 'SR'
          and WORKITEM_PK_ID = p_incident_id;

    begin

    --dbms_output.put_line('Start of Create_Workitem() ');

    --dbms_output.put_line('owner_group_id:' || p_sr_rec.owner_group_id );
    --dbms_output.put_line('owner_group_type:' || p_sr_rec.group_type );

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- First thing to do is check if user wants to use UWQ assignment.
      -- See if service request as a work source is activated.

      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS
          ( p_api_version              => 1.0,
            p_init_msg_list            => fnd_api.g_false,
            p_commit                   => fnd_api.g_false,
            p_ws_code                  => 'SR',
            x_ws_activation_status     => l_sr_activation_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data,
            x_return_status            => l_return_status);

      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         l_sr_activation_status := 'N' ;
      END IF;
      IF (NVL(l_sr_activation_status,'N') = 'Y') THEN

        -- Obtain 'Close Flag' and Work Item Status
	OPEN sel_status_csr;
	FETCH sel_status_csr
	INTO l_wi_status, l_close_flag;
	CLOSE sel_status_csr;

        -- See if work item already exists for SR.
        open sel_sr_wi_csr;
        fetch sel_sr_wi_csr into l_work_item_id;

        IF (sel_sr_wi_csr%NOTFOUND AND l_close_flag = 'N') THEN

        --dbms_output.put_line('Create_Workitem(), Preparing to call CREATE_WR_ITEM ');

	  -- Default all optional fields. UWQ does not have concept of missing
	  -- paramaters , G_MISS_CHAR, etc. So we will have to default to FALSE.

          --dbms_output.put_line('In Workitem API');
          --dbms_output.put_line(' Owner Id : '||p_sr_rec.owner_id);
          --dbms_output.put_line('Owner Type :'||p_sr_rec.resource_type);
          --dbms_output.put_line('Owner Group Type :'||p_sr_rec.group_type);
          --dbms_output.put_line('Owner Group ID :'||p_sr_rec.owner_group_id);

	  IF (p_sr_rec.group_type = FND_API.G_MISS_CHAR) THEN
	    l_owner_group_type := NULL;
	  ELSE
	    l_owner_group_type := p_sr_rec.group_type;
	  END IF;

	  IF (p_sr_rec.owner_group_id = FND_API.G_MISS_NUM) THEN
	    l_owner_group_id := NULL;
	    l_owner_group_type := NULL;
          ELSIF p_sr_rec.owner_group_id IS NULL THEN
            l_owner_group_id := NULL;
            l_owner_group_type := NULL;
	  ELSE
	    l_owner_group_id := p_sr_rec.owner_group_id;
	  END IF;

	  IF (p_sr_rec.resource_type = FND_API.G_MISS_CHAR) THEN
	    l_individual_owner_type := NULL;
	  ELSE
	    l_individual_owner_type := p_sr_rec.resource_type;
	  END IF;

	  IF (p_sr_rec.owner_id = FND_API.G_MISS_NUM) THEN
	    l_individual_owner_id := NULL;
	    l_individual_owner_type := NULL;
          ELSIF p_sr_rec.owner_id IS NULL THEN
            l_individual_owner_id := NULL;
            l_individual_owner_type := NULL;
	  ELSE
	    l_individual_owner_id := p_sr_rec.owner_id;
	  END IF;

          --dbms_output.put_line('After Reassignment');
          --dbms_output.put_line(' Owner Id : '||l_individual_owner_id);
          --dbms_output.put_line('Owner Type :'||l_individual_owner_type);
          --dbms_output.put_line('Owner Group Type :'||l_owner_group_type);
          --dbms_output.put_line('Owner Group ID :'||l_owner_group_id);

          Apply_Priority_Rule
             (P_New_Inc_Responded_By_Date  => p_sr_rec.inc_responded_by_date,
              P_New_Obligation_Date        => p_sr_rec.obligation_date,
              P_New_Exp_Resolution_Date    => p_sr_rec.exp_resolution_date,
              P_New_Severity_id            => p_sr_rec.severity_id ,
              P_Old_Inc_Responded_By_Date  => NULL,
              P_Old_Obligation_Date        => NULL,
              P_Old_Exp_Resolution_Date    => NULL,
              P_Old_Severity_id            => NULL,
              P_Operation_mode             => 'CREATE',
              X_Change_WI_Flag             => l_change_wi_flag,
              X_Due_Date                   => l_due_date,
              X_Priority_Code              => l_priority_code,
              X_Return_Status              => X_Return_Status,
              X_Msg_Count                  => X_Msg_Count,
              X_Msg_Data                   => X_Msg_Data);


	  IF (p_login_id = FND_API.G_MISS_NUM) THEN
	    l_login_id := NULL;
	  ELSE
	    l_login_id :=  p_login_id;
	  END IF;

	  --dbms_output.put_line('B4 calling IEU_WR_PUB.CREATE_WR_ITEM');
	  --dbms_output.put_line('l_owner_group_id:'||l_owner_group_id||' , l_owner_group_type:'|| l_owner_group_type);

	  -- Default these values since NULL not allowed in UWQ.
	  IF (p_resp_appl_id IS NULL) THEN
	    l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
	  END IF;
	  IF (p_user_id IS NULL) THEN
	    l_user_id := FND_GLOBAL.USER_ID;
	  END IF;

          IEU_WR_PUB.CREATE_WR_ITEM(
			p_api_version		=> 1.0,
			p_init_msg_list		=> p_init_msg_list,
			p_commit		=> p_commit,
			p_workitem_obj_code	=> 'SR',
			p_workitem_pk_id	=> p_incident_id,
			p_work_item_number	=> p_incident_number,
			p_title			=> p_sr_rec.summary,
			p_party_id		=> p_sr_rec.customer_id,
			p_priority_code		=> l_priority_code,
			p_due_date		=> l_due_date,
			p_owner_id		=> l_owner_group_id,
			p_owner_type		=> l_owner_group_type,
			p_assignee_id		=> l_individual_owner_id,
			p_assignee_type		=> l_individual_owner_type,
			p_source_object_id	=> null,
			p_source_object_type_code	=> null,
			p_application_id	=> l_resp_appl_id,
			p_ieu_enum_type_uuid	=> 'SR',
			p_work_item_status	=> l_wi_status,
			p_user_id		=> l_user_id,
			p_login_id		=> l_login_id,
			x_work_item_id		=> x_work_item_id,
			x_msg_count		=> x_msg_count,
			x_msg_data		=> x_msg_data,
			x_return_status		=> l_return_status);

	  --dbms_output.put_line('After calling IEU_WR_PUB.CREATE_WR_ITEM');
	  --dbms_output.put_line('l_return_status:' ||l_return_status );

	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    raise l_API_ERROR;
	  END IF;

        END IF;		-- sel_sr_wi_csr%NOTFOUND

        CLOSE sel_sr_wi_csr;

      END IF;	-- FND_PROFILE.value('CS_SR_ENABLE_UWQ_WORKITEM' = 'Y'

      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;


    EXCEPTION

      WHEN l_API_ERROR THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

      WHEN FND_API.G_EXC_ERROR THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

      WHEN OTHERS THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

    END Create_Workitem;


  /******************************************************
   Update_Workitem() -
  ******************************************************/

  PROCEDURE Update_Workitem(
		p_api_version		IN NUMBER,
		p_init_msg_list		IN VARCHAR2 DEFAULT fnd_api.g_false,
		p_commit		IN VARCHAR2 DEFAULT fnd_api.g_false,
		p_incident_id		IN NUMBER,
		p_old_sr_rec IN CS_ServiceRequest_PVT.sr_oldvalues_rec_type,
		p_new_sr_rec IN CS_ServiceRequest_PVT.service_request_rec_type,
		p_user_id		IN NUMBER,	-- Required
		p_resp_appl_id		IN NUMBER,	-- Required
		p_login_id		IN NUMBER DEFAULT NULL,
		x_return_status		OUT	NOCOPY VARCHAR2,
		x_msg_count		OUT	NOCOPY NUMBER,
		x_msg_data		OUT	NOCOPY VARCHAR2) IS

      l_return_status		VARCHAR2(1);
      l_change_wi_attr		VARCHAR2(1) := 'N';
      l_change_wi_attr1		VARCHAR2(1) := 'N';
      l_old_priority		cs_incident_severities_b.priority_code%TYPE;
      l_new_priority            cs_incident_severities_b.priority_code%TYPE;
      l_old_close_flag		cs_incident_statuses_b.close_flag%TYPE;
      l_new_close_flag		cs_incident_statuses_b.close_flag%TYPE;
      l_old_on_hold_flag	cs_incident_statuses_b.on_hold_flag%TYPE;
      l_new_on_hold_flag	cs_incident_statuses_b.on_hold_flag%TYPE;
      l_work_item_status	VARCHAR2(25);
      l_incident_number		VARCHAR2(64);
      l_due_date		DATE;
      l_work_item_id		NUMBER;

      l_owner_id		NUMBER;
      l_resource_type		cs_incidents_all_b.RESOURCE_TYPE%TYPE;
      l_owner_group_id		NUMBER;
      l_group_type		cs_incidents_all_b.GROUP_TYPE%TYPE;
      l_summary			cs_incidents_all_tl.SUMMARY%TYPE;
      l_customer_id		NUMBER;
      l_priority		cs_incident_severities_b.priority_code%TYPE;
      l_new_status_id		NUMBER;
      l_new_severity_id		NUMBER;
      l_inc_responded_by_date	DATE;
      l_obligation_date		DATE;
      l_exp_resolution_date	DATE;
      l_API_ERROR		EXCEPTION;
      l_sr_rec			CS_ServiceRequest_PVT.service_request_rec_type;
      l_resp_appl_id		NUMBER := p_resp_appl_id;
      l_user_id			NUMBER := p_user_id;
      l_sr_activation_status    VARCHAR2(3) := 'N' ;

      cursor sel_sr_wi_csr is
        select work_item_id
        from ieu_uwqm_items
        where WORKITEM_OBJ_CODE = 'SR'
          and WORKITEM_PK_ID = p_incident_id;

      cursor sel_status_flags_csr(l_status_id IN NUMBER) IS
        SELECT nvl(close_flag,'N'),
	       nvl(on_hold_flag,'N')
        FROM   cs_incident_statuses_b
        WHERE  incident_status_id  = l_status_id;

      CURSOR sel_incident_number_csr IS
	SELECT incident_number
	FROM cs_incidents_all_b
	WHERE incident_id = p_incident_id;


    BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- First thing to do is check if user wants to use UWQ assignment.

      -- See if service request as a work source is activated.

      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS
          ( p_api_version              => 1.0,
            p_init_msg_list            => fnd_api.g_false,
            p_commit                   => fnd_api.g_false,
            p_ws_code                  => 'SR',
            x_ws_activation_status     => l_sr_activation_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data,
            x_return_status            => l_return_status);

      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         l_sr_activation_status := 'N' ;
      END IF;

      IF (NVL(l_sr_activation_status,'N') = 'Y') THEN

        -- Next we find out if only significant attributes changed that
	-- will require a change in the work item.

	-- p_new_sr_rec.owner_id could be G_MISS_NUM, so for unchanged field,
	-- we need to set from the old values.
	-- Also, CS store G_MISS_NUM, G_MISS_CHAR, G_MISS_DATE in tables
	-- so we have to default these values to null since UWQ does not
	-- interpret these values correctly.

	IF (Is_Value_Changed(p_old_sr_rec.incident_owner_id,
		             p_new_sr_rec.owner_id)) THEN
	  l_owner_id := p_new_sr_rec.owner_id;
	  l_change_wi_attr := 'Y';
	ELSE
	  l_owner_id := p_old_sr_rec.incident_owner_id;
	END IF;

	IF (Is_Value_Changed(p_old_sr_rec.resource_type,
			     p_new_sr_rec.resource_type)) THEN
	  l_resource_type := p_new_sr_rec.resource_type;
	  l_change_wi_attr := 'Y';
	ELSE
	  l_resource_type := p_old_sr_rec.resource_type;
	END IF;

	IF (Is_Value_Changed(p_old_sr_rec.owner_group_id,
			     p_new_sr_rec.owner_group_id)) THEN
	  l_owner_group_id := p_new_sr_rec.owner_group_id;
	  l_change_wi_attr := 'Y';
	ELSE
	  l_owner_group_id := p_old_sr_rec.owner_group_id;
	END IF;

	--dbms_output.put_line('l_owner_group_id:'||l_owner_group_id);

	IF (Is_Value_Changed(p_old_sr_rec.group_type,
			     p_new_sr_rec.group_type)) THEN
	  l_group_type := p_new_sr_rec.group_type;
	  l_change_wi_attr := 'Y';
	ELSE
	  l_group_type := p_old_sr_rec.group_type;
	END IF;

	--dbms_output.put_line('l_group_type:'||l_group_type);

	IF (Is_Value_Changed(p_old_sr_rec.summary, p_new_sr_rec.summary)) THEN
	  l_summary := p_new_sr_rec.summary;
	  l_change_wi_attr := 'Y';
	ELSE
	  l_summary := p_old_sr_rec.summary;
	END IF;

	IF (Is_Value_Changed(p_old_sr_rec.customer_id,
			     p_new_sr_rec.customer_id)) THEN
	  l_customer_id := p_new_sr_rec.customer_id;
	  l_change_wi_attr := 'Y';
	ELSE
	  l_customer_id := p_old_sr_rec.customer_id;
	END IF;

        -- SR record may not pass new severity id since it may not have changed.
        IF (p_new_sr_rec.severity_id = FND_API.G_MISS_NUM) THEN
          l_new_priority := l_old_priority;
          l_new_severity_id := p_old_sr_rec.incident_severity_id;
        ELSE
          l_new_severity_id := p_new_sr_rec.severity_id;
        END IF;

	-- Determine if we need to update Work Item Due Date
	-- Check if inc_responded_by_date changed from NULL to
	-- NOT NULL and vice versa.

          Apply_Priority_Rule
             (P_New_Inc_Responded_By_Date  => p_new_sr_rec.inc_responded_by_date,
              P_New_Obligation_Date        => p_new_sr_rec.obligation_date,
              P_New_Exp_Resolution_Date    => p_new_sr_rec.exp_resolution_date,
              P_New_Severity_Id            => p_new_sr_rec.severity_id,
              P_Old_Inc_Responded_By_Date  => p_old_sr_rec.inc_responded_by_date,
              P_Old_Obligation_Date        => p_old_sr_rec.obligation_date,
              P_Old_Exp_Resolution_Date    => p_old_sr_rec.expected_resolution_date,
              P_Old_Severity_Id            => p_old_sr_rec.incident_severity_id,
              P_Operation_mode             => 'UPDATE',
              X_Change_WI_Flag             => l_change_wi_attr1,
              X_Due_Date                   => l_due_date,
              X_Priority_Code              => l_priority,
              X_Return_Status              => X_Return_Status,
              X_Msg_Count                  => X_Msg_Count,
              X_Msg_Data                   => X_Msg_Data);


           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              IF l_change_wi_attr1 = 'Y' THEN
                 l_change_wi_attr  := l_change_wi_attr1;
              END IF;
           ELSE
	      x_return_status := l_return_status;
	      raise l_API_ERROR;
	   END IF;

	-- Status may not have changed, but the Status Attributes:
	-- Closed Flag or On Hold Flag could have changed.
	-- Or Status may have changed but it's attributes did not,
	-- so no need to call Update work item API.

	OPEN sel_status_flags_csr(p_old_sr_rec.incident_status_id);
	FETCH sel_status_flags_csr
	INTO l_old_close_flag, l_old_on_hold_flag;
	-- The Status might have been deleted in the set-up form. Not sure
	-- if this is a valid scenario.
	IF sel_status_flags_csr%NOTFOUND THEN
	  NULL;
	END IF;
	CLOSE sel_status_flags_csr;

	-- SR record may not pass new status id since it may not have changed.
	IF (p_new_sr_rec.status_id = FND_API.G_MISS_NUM) THEN
	  l_new_status_id := p_old_sr_rec.incident_status_id;
	  l_new_close_flag := l_old_close_flag;
	  l_new_on_hold_flag := l_old_on_hold_flag;
	ELSE
	  l_new_status_id := p_new_sr_rec.status_id;
	  OPEN sel_status_flags_csr(p_new_sr_rec.status_id);
	  FETCH sel_status_flags_csr
	  INTO l_new_close_flag, l_new_on_hold_flag;
	  CLOSE sel_status_flags_csr;
	END IF;

	-- This check needs to go first . When changing to Status with 'Close'
	-- and 'On Hold' flag turned on, Work Item Status should be
	-- 'CLOSE', not 'SLEEP'.

	IF (l_old_close_flag <> l_new_close_flag) THEN

          l_change_wi_attr := 'Y';
          IF (l_new_close_flag = 'Y') THEN
            l_work_item_status := 'CLOSE';
          ELSIF (l_new_on_hold_flag = 'Y') THEN
            l_work_item_status := 'SLEEP';
          ELSE
            l_work_item_status := 'OPEN';
          END IF;

        ELSE

          IF (l_new_on_hold_flag = 'Y') THEN
            l_work_item_status := 'SLEEP';
          ELSE
            l_work_item_status := 'OPEN';
          END IF;
          IF (l_old_on_hold_flag <> l_new_on_hold_flag) THEN
            l_change_wi_attr := 'Y';
          END IF;

        END IF;


        -- CS stores G_MISS_NUM, G_MISS_CHAR, G_MISS_DATE in tables
        -- so we have to default these values to null since UWQ does not
        -- interpret these values correctly.

        IF (l_resource_type = FND_API.G_MISS_CHAR) THEN
          l_resource_type := NULL;
        END IF;

        IF (l_owner_id = FND_API.G_MISS_NUM) THEN
          l_owner_id := NULL;
          l_resource_type := NULL;
        ELSIF l_owner_id IS NULL THEN
          l_resource_type := NULL;
        END IF;

        IF (l_group_type = FND_API.G_MISS_CHAR) THEN
          l_group_type := NULL;
        END IF;

        IF (l_owner_group_id = FND_API.G_MISS_NUM) THEN
          l_owner_group_id := NULL;
          l_group_type := NULL;
        ELSIF l_owner_group_id IS NULL THEN
          l_group_type := NULL;
        END IF;

        IF (l_summary = FND_API.G_MISS_CHAR) THEN
          l_summary := NULL;
        END IF;
        IF (l_customer_id = FND_API.G_MISS_NUM) THEN
          l_customer_id := NULL;
        END IF;

        IF (l_priority = FND_API.G_MISS_CHAR) THEN
          l_priority := NULL;
        END IF;
        IF (l_due_date = FND_API.G_MISS_DATE) THEN
          l_due_date := NULL;
        END IF;

	/************************************************/

        -- See if work item already exists for SR.
        open sel_sr_wi_csr;
        fetch sel_sr_wi_csr into l_work_item_id;

        IF (sel_sr_wi_csr%FOUND AND l_work_item_id IS NOT NULL) THEN

	  IF (l_change_wi_attr = 'Y') THEN

	    -- Default these values since NULL not allowed in UWQ.
	    IF (p_resp_appl_id IS NULL) THEN
	      l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
	    END IF;
	    IF (p_user_id IS NULL) THEN
	      l_user_id := FND_GLOBAL.USER_ID;
	    END IF;

            IEU_WR_PUB.UPDATE_WR_ITEM(
			p_api_version		=> 1.0,
			p_init_msg_list		=> p_init_msg_list,
			p_commit 		=> p_commit,
			p_workitem_obj_code	=> 'SR',
			p_workitem_pk_id	=> p_incident_id,
			p_title			=> l_summary,
			p_party_id		=> l_customer_id,
			p_priority_code		=> l_priority,
			p_due_date		=> l_due_date,
			p_owner_id		=> l_owner_group_id,
			p_owner_type		=> l_group_type,
			p_assignee_id		=> l_owner_id,
			p_assignee_type		=> l_resource_type,
			p_source_object_id	=> NULL,
			p_source_object_type_code	=> NULL,
			p_application_id	=> l_resp_appl_id,
			p_work_item_status	=> l_work_item_status,
			p_user_id		=> l_user_id,
			p_login_id              => p_login_id,
			x_msg_count		=> x_msg_count,
			x_msg_data		=> x_msg_data,
			x_return_status		=> l_return_status
			);

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_return_status := l_return_status;
	      raise l_API_ERROR;
	    END IF;


	  END IF;	-- l_change_wi_attr = 'Y'


        ELSE	-- sel_sr_wi_csr%FOUND OR l_work_item_id IS NOT NULL

	  CS_ServiceRequest_PVT.initialize_rec(l_sr_rec);

	  OPEN sel_incident_number_csr;
	  FETCH sel_incident_number_csr INTO l_incident_number;
	  CLOSE sel_incident_number_csr;

	  l_sr_rec.owner_group_id := l_owner_group_id;
	  l_sr_rec.group_type := l_group_type;
	  l_sr_rec.owner_id := l_owner_id;
	  l_sr_rec.resource_type := l_resource_type;
	  l_sr_rec.status_id := l_new_status_id;
	  l_sr_rec.severity_id := l_new_severity_id;
	  l_sr_rec.customer_id := l_customer_id;
	  l_sr_rec.summary := l_summary;
	  l_sr_rec.inc_responded_by_date := l_inc_responded_by_date;
	  l_sr_rec.obligation_date := l_obligation_date;
	  l_sr_rec.exp_resolution_date := l_exp_resolution_date;

	  --dbms_output.put_line('Calling IEU_WR_PUB.CREATE_WR_ITEM');

	  --dbms_output.put_line('l_owner_group_id:'||l_owner_group_id);
	  --dbms_output.put_line('l_group_type:'||l_group_type);

	  CS_SR_WORKITEM_PVT.Create_Workitem(
		p_api_version		=> 1.0,
		p_init_msg_list		=> p_init_msg_list,
		p_commit		=> p_commit,
		p_incident_id		=> p_incident_id,
		p_incident_number	=> l_incident_number,
		p_sr_rec		=> l_sr_rec,
		p_user_id		=> p_user_id,
		p_resp_appl_id		=> p_resp_appl_id,
		p_login_id		=> p_login_id,
		x_work_item_id		=> l_work_item_id,
		x_return_status		=> l_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data);


	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    raise l_API_ERROR;
	  END IF;


        END IF;	-- sel_sr_wi_csr%FOUND OR l_work_item_id IS NOT NULL

        close sel_sr_wi_csr;

      END IF;	-- FND_PROFILE.value('CS_SR_ENABLE_UWQ_WORKITEM' = 'Y')

      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;

    EXCEPTION

      WHEN l_API_ERROR THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

      WHEN FND_API.G_EXC_ERROR THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

      WHEN OTHERS THEN
	IF (sel_sr_wi_csr%ISOPEN) THEN
	  CLOSE sel_sr_wi_csr;
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
		( p_count => x_msg_count,
		  p_data  => x_msg_data );

    END Update_Workitem;


  /******************************************************
   FUNCTION Is_Value_Changed()
  ******************************************************/

  FUNCTION Is_Value_Changed(
		p_old_val	IN VARCHAR2,
		p_new_val	IN VARCHAR2) RETURN BOOLEAN IS

    BEGIN

      IF (p_new_val = FND_API.G_MISS_CHAR) THEN
	return false;
      ELSIF ( (p_old_val IS NOT NULL AND p_new_val IS NULL) OR
	      (p_old_val IS NULL AND p_new_val IS NOT NULL) OR
	      (p_old_val IS NOT NULL AND p_new_val IS NOT NULL AND
	       p_old_val <> p_new_val) ) THEN
        return true;
      ELSE
	return false;
      END IF;

    END Is_Value_Changed;

  /******************************************************
   FUNCTION Is_Value_Changed()
  ******************************************************/

  FUNCTION Is_Value_Changed(
		p_old_val	IN NUMBER,
		p_new_val	IN NUMBER) RETURN BOOLEAN IS

  BEGIN

      IF (p_new_val = FND_API.G_MISS_NUM) THEN
	return false;
      ELSIF ( (p_old_val IS NOT NULL AND p_new_val IS NULL) OR
	      (p_old_val IS NULL AND p_new_val IS NOT NULL) OR
	      (p_old_val IS NOT NULL AND p_new_val IS NOT NULL AND
	       p_old_val <> p_new_val) ) THEN
        return true;
      ELSE
	return false;
      END IF;

  END Is_Value_Changed;

  /******************************************************
   FUNCTION Is_Value_Changed()
  ******************************************************/

  FUNCTION Is_Value_Changed(
		p_old_val	IN DATE,
		p_new_val	IN DATE) RETURN BOOLEAN IS

    BEGIN

      IF (p_new_val = FND_API.G_MISS_DATE) THEN
	return false;
      ELSIF ( (p_old_val IS NOT NULL AND p_new_val IS NULL) OR
	      (p_old_val IS NULL AND p_new_val IS NOT NULL) OR
	      (p_old_val IS NOT NULL AND p_new_val IS NOT NULL AND
	       p_old_val <> p_new_val) ) THEN
        return true;
      ELSE
	return false;
      END IF;

    END Is_Value_Changed;




 /********************************************************
  Procedure Set priority rules
  Description : This procedure derives the

 *********************************************************/

PROCEDURE Apply_Priority_Rule
           (P_New_Inc_Responded_By_Date     IN        DATE,
            P_New_Obligation_Date           IN        DATE,
            P_New_Exp_Resolution_Date       IN        DATE,
            P_New_Severity_Id               IN        NUMBER,
            P_Old_Inc_Responded_By_Date     IN        DATE,
            P_Old_Obligation_Date           IN        DATE,
            P_Old_Exp_Resolution_Date       IN        DATE,
            P_Old_Severity_Id               IN        NUMBER,
            P_Operation_mode                IN        VARCHAR2,
            X_Change_WI_Flag               OUT NOCOPY VARCHAR2,
            X_Due_Date                     OUT NOCOPY DATE,
            X_Priority_Code                OUT NOCOPY VARCHAR2,
            X_Return_Status                OUT NOCOPY VARCHAR2,
            X_Msg_Count                    OUT NOCOPY NUMBER,
            X_Msg_Data                     OUT NOCOPY VARCHAR2) IS


l_new_priority_code     cs_incident_severities_b.priority_code%TYPE;
l_old_priority_code     cs_incident_severities_b.priority_code%TYPE;
l_inc_responded_by_date DATE;
l_obligation_date       DATE;
l_exp_resolution_date   DATE;

CURSOR c_get_priority_code (l_severity_id IN NUMBER) IS
       SELECT priority_code
         FROM cs_incident_severities_b
	WHERE incident_severity_id = l_severity_id;

BEGIN

 X_Return_Status := FND_API.G_RET_STS_SUCCESS;

 IF p_operation_mode = 'CREATE' THEN       -- Operation Mode

    IF p_new_inc_responded_by_date = FND_API.G_MISS_DATE THEN
       l_Inc_responded_by_date := NULL;
    ELSE
       l_Inc_responded_by_date := p_new_inc_responded_by_date;
    END IF;

    IF P_New_obligation_date = FND_API.G_MISS_DATE THEN
       l_obligation_date := NULL;
    ELSE
       l_obligation_date := P_New_obligation_date;
    END IF;

    IF P_New_exp_resolution_date = FND_API.G_MISS_DATE THEN
       l_exp_resolution_date := NULL;
    ELSE
       l_exp_resolution_date := P_New_exp_resolution_date;
    END IF;

    IF l_Inc_responded_by_date is NULL THEN
       X_due_date := l_obligation_date;
    ELSE
       X_due_date := l_exp_resolution_date;
    END IF;

    -- Set the Priority Code

     OPEN c_get_priority_code (P_New_Severity_Id) ;
    FETCH c_get_priority_code INTO l_new_priority_code;
    CLOSE c_get_priority_code ;

    X_Priority_Code := l_new_priority_code;

 ELSE --p_operation_mode = 'UPDATE' THEN       -- Operation Mode

    IF ((p_old_inc_responded_by_date IS NULL AND
         p_new_inc_responded_by_date IS NOT NULL AND
	 p_new_inc_responded_by_date <> FND_API.G_MISS_DATE) OR
	(p_old_inc_responded_by_date IS NOT NULL AND
	 p_new_inc_responded_by_date IS NULL)
       ) THEN

       --Set value for Due Date work item parameter
       IF (p_new_inc_responded_by_date IS NULL) THEN
	  X_due_date := p_new_obligation_date;
       ELSE
	  X_due_date := p_new_exp_resolution_date;
       END IF;

       X_change_wi_flag := 'Y';

	-- 'Respond On' date may not have changed, but either 'Respond By' or
	-- 'Resolution By' date did.
    ELSE
         IF p_old_inc_responded_by_date IS NULL THEN
	    IF (Is_Value_Changed(p_old_obligation_date, p_new_obligation_date)) THEN
	      X_due_date := p_new_obligation_date;
	      X_change_wi_flag := 'Y';
	    ELSE
	      -- We still need to set due_date to current due_date as required
	      -- in UWQ API and passing null updates UWQ schema to NULL.
	      X_due_date := p_old_obligation_date;
	    END IF;
	  ELSE
	    IF (Is_Value_Changed(p_old_exp_resolution_date,
                                 p_new_exp_resolution_date)) THEN
	      X_due_date := p_new_exp_resolution_date;
	      X_change_wi_flag := 'Y';
	    ELSE
	      X_due_date := p_old_exp_resolution_date;
	    END IF;
	  END IF;
    END IF; -- End of: Determine if we need to update Work Item Due Date.

     -- Derive the responded by and resolve on dates.

    IF p_new_inc_responded_by_date = FND_API.G_MISS_DATE THEN
       l_inc_responded_by_date := p_old_inc_responded_by_date;
    ELSE
       l_inc_responded_by_date := p_new_inc_responded_by_date;
    END IF;

    IF p_new_obligation_date = FND_API.G_MISS_DATE THEN
       l_obligation_date := p_old_obligation_date;
    ELSE
       l_obligation_date := p_new_obligation_date;
    END IF;

    IF p_new_exp_resolution_date = FND_API.G_MISS_DATE THEN
       l_exp_resolution_date := p_old_exp_resolution_date;
    ELSE
       l_exp_resolution_date := p_new_exp_resolution_date;
    END IF;

    -- Set the priority cdoe

      -- Get the priority code for the new severity

     OPEN c_get_priority_code (P_Old_Severity_Id) ;
    FETCH c_get_priority_code INTO l_Old_priority_code;

       IF c_get_priority_code%NOTFOUND THEN
          NULL;
       END IF;

    CLOSE c_get_priority_code ;

     -- SR record may not pass new severity id since it may not have changed.
        IF p_new_Severity_Id = FND_API.G_MISS_NUM THEN
           l_new_priority_code := l_old_priority_code;
        ELSE
           OPEN c_get_priority_code (P_New_Severity_Id) ;
          FETCH c_get_priority_code INTO l_new_priority_code;
          CLOSE c_get_priority_code;
        END IF ;

        IF (Is_Value_Changed(l_Old_priority_code,l_new_priority_code)) THEN
            X_change_wi_flag := 'Y';
            X_Priority_Code := l_New_priority_code;
        ELSE
            X_Priority_Code := l_Old_priority_code;
        END IF ;

 END IF ;       -- Operation Mode

EXCEPTION
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data );

END Apply_Priority_Rule;

END CS_SR_WORKITEM_PVT;

/
