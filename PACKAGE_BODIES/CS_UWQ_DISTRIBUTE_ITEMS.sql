--------------------------------------------------------
--  DDL for Package Body CS_UWQ_DISTRIBUTE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_UWQ_DISTRIBUTE_ITEMS" AS
/* $Header: csvsrwdb.pls 120.7 2006/08/22 00:01:43 nveerara noship $ */

/*****************************************
--  This procdeure is going to be called by UWQ's distribute_function()
--  to update owner of Service Request in CS when the WI is assigned
--  to an individual owner
--  Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  05/25/2004  RMANABAT    Fix for bug 3612904. Passed resp_id and
--                          rep_appL_id to update_servicerequest() api
--                          for security validation.
*******************************************/

  PROCEDURE Distribute_ServiceRequests
		(P_RESOURCE_ID		IN NUMBER,
		P_LANGUAGE		IN VARCHAR2,
		P_SOURCE_LANG		IN VARCHAR2,
		P_NUM_OF_ITEMS		IN NUMBER,
		P_DIST_BUS_RULES	IN SYSTEM.DIST_BUS_RULES_NST,
		P_WS_INPUT_DATA		IN OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
		X_MSG_COUNT		OUT NOCOPY NUMBER,
		X_MSG_DATA		OUT NOCOPY VARCHAR2,
		X_RETURN_STATUS		OUT NOCOPY VARCHAR2) IS


    l_distributed_from varchar2(100);
    l_distributed_to varchar2(100);
    l_grp_owner varchar2(100);
    l_individual_owner varchar2(100);

    l_notes			CS_SERVICEREQUEST_PVT.notes_table;
    l_contacts			CS_SERVICEREQUEST_PVT.contacts_table;
    out_interaction_id		NUMBER;
    out_wf_process_id		NUMBER;
    l_return_status		VARCHAR2(1);
    l_msg_count			NUMBER;
    l_msg_data			VARCHAR2(2000);

    l_incident_number		VARCHAR2(64);
    l_object_version_number	NUMBER;
    l_incident_owner_id		NUMBER;
    l_assignee_id		NUMBER;
    l_resource_type		VARCHAR2(33);

    CURSOR sel_servereq_csr(l_request_id IN NUMBER) IS
      SELECT incident_number,
	     object_version_number,
	     incident_owner_id
      FROM cs_incidents_all_b
      WHERE incident_id = l_request_id;

    CURSOR sel_resource_type_csr IS
      SELECT 'RS_' || category
      FROM jtf_rs_resource_extns
      WHERE RESOURCE_ID = P_RESOURCE_ID;

    CURSOR sel_wi_owner_csr(l_request_id IN NUMBER) IS
      SELECT assignee_id
      FROM ieu_uwqm_items
      WHERE workitem_obj_code = 'SR'
	AND workitem_pk_id = l_request_id;

    l_msg_index_OUT       NUMBER;


    BEGIN


      -- Establish savepoint
      SAVEPOINT Distribute_SR;
      --dbms_output.put_line('Starting Distribute SR ');

      --insert into rm_tmp values(null,null,'start of SR distribute func',rm_tmp_seq.nextval);
      --commit;

      -- Loop thru the Business rules per Work Source
      For i in P_DIST_BUS_RULES.first .. P_DIST_BUS_RULES.last
      Loop

        l_distributed_from :=  P_DIST_BUS_RULES(i).DISTRIBUTE_FROM;
        l_distributed_to :=  P_DIST_BUS_RULES(i).DISTRIBUTE_TO;

        -- For each Work Source,Get the Details of the Work Item to be distributed and the
        -- Distribution Rules. Try to Distribute the Work Item.
        IF (P_DIST_BUS_RULES(i).work_source = 'SR') THEN

	  --dbms_output.put_line('Distribute SR, P_DIST_BUS_RULES.work_source=SR ');

	  -- Loop thru Work Item Details
          For j in P_WS_INPUT_DATA.first .. P_WS_INPUT_DATA.last
          LOOP

	    IF (P_WS_INPUT_DATA(j).Work_source= 'SR' AND
		l_distributed_from = 'GROUP_OWNED') THEN
		-- Commented out since we don't have any special logic regarding
		--  distribute_to
		-- l_distributed_to = 'INDIVIDUAL_ASSIGNED') THEN

		--dbms_output.put_line('Distribute SR, P_WS_INPUT_DATA.work_source=SR ');


	      -- Obtain Resource Type of the resource
	      OPEN sel_resource_type_csr;
	      FETCH sel_resource_type_csr INTO l_resource_type;
	      CLOSE sel_resource_type_csr;


	      OPEN sel_servereq_csr(P_WS_INPUT_DATA(j).WORKITEM_PK_ID);
	      FETCH sel_servereq_csr
	      INTO l_incident_number, l_object_version_number,l_incident_owner_id;
	      CLOSE sel_servereq_csr;

	      --dbms_output.put_line('Distribute SR, Calling Update SR_UWQ ');


	      CS_ServiceRequest_PVT.Update_Owner(
			p_api_version		=> 2.0,
			p_init_msg_list		=> fnd_api.g_false,
			p_commit		=> fnd_api.g_false,
			p_validation_level	=> fnd_api.g_valid_level_full,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data,
			p_request_id		=> P_WS_INPUT_DATA(j).WORKITEM_PK_ID,
			p_object_version_number	=> l_object_version_number,
			--p_resp_id		=> NULL,
			--p_resp_appl_id	=> P_WS_INPUT_DATA(j).APPLICATION_ID,
			p_resp_id		=> fnd_global.resp_id,
			p_resp_appl_id		=> fnd_global.resp_appl_id,
			p_owner_id		=> P_RESOURCE_ID,
			p_owner_group_id	=> P_WS_INPUT_DATA(j).OWNER_ID,
			p_resource_type		=> l_resource_type,
			p_last_updated_by	=> FND_GLOBAL.USER_ID,
			p_last_update_login	=> NULL,
			p_last_update_date	=> sysdate,
			p_audit_comments	=> NULL,
			p_called_by_workflow	=> fnd_api.g_false,
			p_workflow_process_id	=> NULL,
			p_comments		=> NULL,
			p_public_comment_flag	=> fnd_api.g_false,
			p_parent_interaction_id	=> NULL,
			x_interaction_id	=> out_interaction_id);

	      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

		-- An error return status from Update_WorkItem() API
		-- is ignored by Update_Owner(), so we have to test that
		-- the owner update was successful for the SR and the
		-- Work Item.

		OPEN sel_servereq_csr(P_WS_INPUT_DATA(j).WORKITEM_PK_ID);
		FETCH sel_servereq_csr
		INTO l_incident_number, l_object_version_number,l_incident_owner_id;
		CLOSE sel_servereq_csr;

		OPEN sel_wi_owner_csr(P_WS_INPUT_DATA(j).WORKITEM_PK_ID);
		FETCH sel_wi_owner_csr INTO l_assignee_id;
		CLOSE sel_wi_owner_csr;

		IF (l_incident_owner_id = P_RESOURCE_ID AND
		    l_assignee_id = P_RESOURCE_ID) THEN

		  P_WS_INPUT_DATA(j).DISTRIBUTED := 'TRUE';
		  P_WS_INPUT_DATA(j).ASSIGNEE_ID := P_RESOURCE_ID;
		  P_WS_INPUT_DATA(j).ASSIGNEE_TYPE := 'RS_INDIVIDUAL';
		  P_WS_INPUT_DATA(j).ITEM_INCLUDED_BY_APP := 'FALSE';

		  COMMIT;

		ELSE

		  ROLLBACK TO Distribute_SR;
		  P_WS_INPUT_DATA(j).DISTRIBUTED := 'FALSE';

		END IF;

	      ELSE

		-- Rollback to savepoint
		ROLLBACK TO Distribute_SR;

		P_WS_INPUT_DATA(j).DISTRIBUTED := 'FALSE';

	      END IF;

	    END IF;

	  END LOOP;

	END IF;

      END LOOP;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  END Distribute_ServiceRequests;


  PROCEDURE SYNC_SR_TASKS(
        P_TASKS_DATA    IN              SYSTEM.WR_TASKS_DATA_NST,
        P_DEF_WR_DATA   IN              SYSTEM.DEF_WR_DATA_NST,
        X_MSG_COUNT     OUT NOCOPY      NUMBER,
        X_MSG_DATA      OUT NOCOPY      VARCHAR2,
        X_RETURN_STATUS OUT NOCOPY      VARCHAR2) AS

    l_work_item_id      NUMBER;
    l_msg_count         NUMBER;
    l_assignee_id       NUMBER := NULL;
    l_owner_id          NUMBER := NULL;
    l_orig_grpowner     NUMBER := NULL;
    l_task_status_id    NUMBER := NULL;
    l_group_member_id   NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(1);
    l_assignee_type     VARCHAR2(30) := NULL;
    l_owner_type        VARCHAR2(30) := NULL;
    l_priority_code     VARCHAR2(30) := 'LOW';
    l_task_status       VARCHAR2(30);
    l_wi_flag           VARCHAR2(1);
    l_due_date          DATE;

  BEGIN

    --dbms_output.put_line('In SYNC SR Tasks, BEGIN ');
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.put_line('In SYNC SR Tasks, BEGIN, X_RETURN_STATUS='|| X_RETURN_STATUS );

    -- Get the Priority Code, WorkItem Status and Due Date
    FOR i in P_DEF_WR_DATA.FIRST..P_DEF_WR_DATA.LAST
    LOOP --LP1
      l_due_date      := p_def_wr_data(i).due_date;
      l_task_status   := p_def_wr_data(i).work_item_status;
      l_priority_code := p_def_wr_data(i).priority_code;
      l_orig_grpowner := p_def_wr_data(i).original_grp_owner;
    END LOOP; --LP1

    -- Loop thru Task Details
    FOR j in P_TASKS_DATA.first.. P_TASKS_DATA.last
    LOOP --LP2
      -- Work Items should be synched up only during Create/Update/Delete task
      -- Assignee Id and type are not considered here
      --dbms_output.put_line('In SYNC SR Tasks, proc_type ='||p_tasks_data(j).proc_type);

      IF (p_tasks_data(j).proc_type = 'CREATE_TASK') OR --IF1
         (p_tasks_data(j).proc_type = 'UPDATE_TASK') OR
         (p_tasks_data(j).proc_type = 'DELETE_TASK') THEN
        --dbms_output.put_line('In SYNC SR Tasks, task_id ='||p_tasks_data(j).task_id);

        IF (p_tasks_data(j).owner_type_code = 'RS_GROUP') THEN --IF2
           l_owner_id := p_tasks_data(j).owner_id;
           l_owner_type := p_tasks_data(j).owner_type_code;
        ELSIF ( (p_tasks_data(j).owner_type_code <> 'RS_GROUP') AND --IF2
              (p_tasks_data(j).owner_type_code <> 'RS_TEAM') ) THEN
          l_assignee_id := p_tasks_data(j).owner_id;
          l_assignee_type := p_tasks_data(j).owner_type_code;
          -- If the Tasks Owner is an individual,
	  -- Select the previous Group Owner
          -- Check if this Individual is a member of the Previous Group
          -- Set the UWQ Owner, assignee based on the these validation
          IF l_orig_grpowner IS NOT NULL THEN
             l_owner_id   := l_orig_grpowner;
       	     l_owner_type := 'RS_GROUP';
          END IF;

        END IF; --IF2

        -- Query for work item if it already exists for this Task
        BEGIN
          SELECT 'Y'
          INTO   l_wi_flag
          FROM   ieu_uwqm_items
          WHERE  workitem_obj_code = 'TASK'
          AND    workitem_pk_id = p_tasks_data(j).task_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_wi_flag := 'N';
        END;

        IF (l_wi_flag = 'N') THEN --IF3
          --dbms_output.put_line('Creating Work Item for Task '||p_tasks_data(j).task_number);
          IEU_WR_PUB.CREATE_WR_ITEM(
                p_api_version             => 1.0,
                p_init_msg_list           => FND_API.G_TRUE,
                p_commit                  => FND_API.G_FALSE,
                p_workitem_obj_code       => 'TASK',
                p_workitem_pk_id          => p_tasks_data(j).task_id,
                p_work_item_number        => p_tasks_data(j).task_number,
                p_title                   => p_tasks_data(j).task_name,
                p_party_id                => p_tasks_data(j).customer_id,
                p_priority_code           => l_priority_code,
                p_due_date                => l_due_date,
                p_owner_id                => l_owner_id,
	        p_owner_type              => l_owner_type,
                p_assignee_id             => l_assignee_id,
                p_assignee_type           => l_assignee_type,
                p_source_object_id        => p_tasks_data(j).source_object_id,
                p_source_object_type_code => p_tasks_data(j).source_object_type_code,
                p_application_id          => 170,
                p_ieu_enum_type_uuid      => 'TASKS',    -- 'IEU_MY_TASKS_OWN',
                p_work_item_status        => l_task_status,
                p_user_id                 => FND_GLOBAL.USER_ID,
                p_login_id                => FND_GLOBAL.LOGIN_ID,
                x_work_item_id            => l_work_item_id,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data,
                x_return_status           => l_return_status);
	ELSE --IF3
          --dbms_output.put_line('Updating Work Item for Task '||p_tasks_data(j).task_number);
          IEU_WR_PUB.UPDATE_WR_ITEM(
                p_api_version             => 1.0,
                p_init_msg_list           => FND_API.G_TRUE,
                p_commit                  => FND_API.G_FALSE,
                p_workitem_obj_code       => 'TASK',
                p_workitem_pk_id          => p_tasks_data(j).task_id,
                p_title                   => p_tasks_data(j).task_name,
                p_party_id                => p_tasks_data(j).customer_id,
                p_priority_code           => l_priority_code,
                p_due_date                => l_due_date,
                p_owner_id                => l_owner_id,
                p_owner_type              => l_owner_type,
                p_assignee_id             => l_assignee_id,
                p_assignee_type           => l_assignee_type,
                p_source_object_id        => p_tasks_data(j).source_object_id,
                p_source_object_type_code => p_tasks_data(j).source_object_type_code,
                p_application_id          => 170,
                p_work_item_status        => l_task_status,
                p_user_id                 => FND_GLOBAL.USER_ID,
                p_login_id                => FND_GLOBAL.LOGIN_ID,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data,
                x_return_status           => l_return_status);
          --dbms_output.put_line('Update l_return_status='||l_return_status);
        END IF; --IF3
      END IF; --IF1
    END LOOP; --LP2

    x_return_status := l_return_status;
    --dbms_output.put_line('SYNC_SR_TASKS  x_return_status='||x_return_status);

  END SYNC_SR_TASKS;


  PROCEDURE SYNC_SR_TASKS(
        P_PROCESSING_SET_ID IN              NUMBER DEFAULT NULL,
        X_MSG_COUNT         OUT NOCOPY      NUMBER,
        X_MSG_DATA          OUT NOCOPY      VARCHAR2,
        X_RETURN_STATUS     OUT NOCOPY      VARCHAR2) AS


    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);
    l_return_status VARCHAR2(1);

  BEGIN
--dbms_output.put_line('In SYNC SR Tasks, BEGIN ');

        l_return_status := FND_API.G_RET_STS_SUCCESS;
--dbms_output.put_line('In SYNC SR Tasks, BEGIN, X_RETURN_STATUS='|| l_RETURN_STATUS );


        BEGIN
         UPDATE IEU_UWQM_ITEMS_GTT A
         SET   A.APPLICATION_ID = 170
         WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID;
--        EXCEPTION
--         WHEN others THEN null;
        END;


        -- Set the Owner/Assignee in UWQ based on the Owner Type Code
        -- Required Group Validation can be done here

          -- If the Tasks Owner is an individual,
          -- Select the previous Group Owner
          -- Check if this Individual is a member of the Previous Group
          -- Set the UWQ Owner, assignee based on the these validation

          -- IF individual owner is NOT member of group (to be obtained from UWQ
          -- owner info with owner type ='GROUP') , nullify group owner info in UWQ
          -- and set assignee to the individual task owner .
          -- Else if individual IS  member of group, just set assignee to the
          -- individual task owner

        BEGIN
         UPDATE IEU_UWQM_ITEMS_GTT A
         SET   A.ASSIGNEE_ID = A.OWNER_ID
             , A.ASSIGNEE_TYPE_ACTUAL = A.OWNER_TYPE_ACTUAL
         WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND A.OWNER_TYPE_ACTUAL NOT IN ('RS_GROUP', 'RS_TEAM');

         UPDATE IEU_UWQM_ITEMS_GTT A
         SET   A.OWNER_ID = ''
             , A.OWNER_TYPE_ACTUAL = ''
         WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND A.OWNER_TYPE_ACTUAL NOT IN ('RS_GROUP', 'RS_TEAM')
         AND NOT EXISTS
             ( SELECT 1
               FROM   JTF_RS_GROUP_MEMBERS B
                    , IEU_UWQM_ITEMS C
               WHERE B.RESOURCE_ID = A.OWNER_ID
               AND B.GROUP_ID = C.OWNER_ID
               AND A.WORKITEM_OBJ_CODE = 'TASK'
               AND C.WORKITEM_PK_ID = A.WORKITEM_PK_ID
               AND C.WORKITEM_OBJ_CODE = A.WORKITEM_OBJ_CODE
               AND C.OWNER_TYPE = 'RS_GROUP'
               AND C.OWNER_ID IS NOT NULL);

--        EXCEPTION
--         WHEN others THEN null;
        END;

        IEU_WR_PUB.SYNC_WR_ITEMS  (
              p_api_version  => 1.0,
              p_init_msg_list => FND_API.G_TRUE,
              p_commit => FND_API.G_FALSE,
              p_processing_set_id => P_PROCESSING_SET_ID,
              p_user_id  => FND_GLOBAL.USER_ID,
              p_login_id => FND_GLOBAL.LOGIN_ID,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_return_status => l_return_status);


        x_return_status := l_return_status;
--dbms_output.put_line('In SYNC SR Tasks, end, X_RETURN_STATUS='|| X_RETURN_STATUS );


  END SYNC_SR_TASKS;




  PROCEDURE DISTRIBUTE_SRTASKS
  (P_RESOURCE_ID		IN NUMBER,
   P_LANGUAGE            	IN VARCHAR2,
   P_SOURCE_LANG      	IN VARCHAR2,
   P_NUM_OF_ITEMS     	IN NUMBER,
   P_DIST_BUS_RULES  	IN SYSTEM.DIST_BUS_RULES_NST,
   P_WS_INPUT_DATA   	IN OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
   X_MSG_COUNT		OUT NOCOPY NUMBER,
   X_MSG_DATA		OUT NOCOPY VARCHAR2,
   X_RETURN_STATUS	OUT NOCOPY VARCHAR2) IS

     l_distributed_from varchar2(100);
     l_distributed_to varchar2(100);
     l_dist_st_based_on_parent_flag varchar2(1);

     l_grp_owner number;
     l_group_id   varchar2(1);
     l_task_distributed_to  number;

     l_source_object_id number;
     l_source_object_code varchar2(30);
     l_distribution_status number;

     l_msg_count number;
     l_msg_data varchar2(2000);
     l_return_status varchar2(1);
     l_task_assignment_id  number;
     l_assignment_id       number;
     l_object_version_number number;
     l_status_id	NUMBER;

     CURSOR sel_tasks_csr(p_task_id IN NUMBER) IS
        SELECT task_id,
                object_version_number,
                task_priority_id
        FROM    jtf_tasks_b
        WHERE   task_id = p_task_id;

      sel_tasks_rec     sel_tasks_csr%ROWTYPE;

     CURSOR sel_jtf_category_csr(p_resource_id IN NUMBER) IS
       SELECT 'RS_' || CATEGORY
       FROM jtf_rs_resource_extns
       WHERE RESOURCE_ID = p_resource_id;

     l_category		VARCHAR2(35);

  BEGIN

--insert into rm_tmp values (null,null,'start of DISTRIBUTE_SRTASKS ',rm_tmp_seq.nextval);
--commit;

    -- initialize to success first
    x_return_status := 'I';

    if p_dist_bus_rules.count <= 0 then
       x_return_status := 'E';
    end if;
    if p_ws_input_data.count <= 0 then
       x_return_status := 'E';
    end if;

    -- Loop thru the Business rules per Work Source

    For i  in P_DIST_BUS_RULES.first.. P_DIST_BUS_RULES.last
    Loop

--insert into rm_tmp values (null,null,'DISTRIBUTE_SRTASKS: Looping P_DIST_BUS_RULES ',rm_tmp_seq.nextval);
--commit;
      --insert into temp_f values('in the first loop');commit;

      l_distributed_from :=  P_DIST_BUS_RULES(i).DISTRIBUTE_FROM;
      l_distributed_to :=  P_DIST_BUS_RULES(i).DISTRIBUTE_TO;
      l_dist_st_based_on_parent_flag := P_DIST_BUS_RULES(i).DIST_ST_BASED_ON_PARENT_FLAG;

      -- For each Work Source, Get the Details of the Work Item to be distributed and the
      --   Distribution Rules. Try to Distribute the Work Item.

      if (P_DIST_BUS_RULES(i).work_source = 'SR_TASKS')
      then

        -- Loop thru Work Item Details
        For j in p_WS_INPUT_DATA .first.. p_WS_INPUT_DATA.last
        loop

--insert into rm_tmp values (null,null,'DISTRIBUTE_SRTASKS: Looping p_WS_INPUT_DATA ',rm_tmp_seq.nextval);
--commit;
          IF (p_WS_INPUT_DATA(j).Work_source = 'SR_TASKS') THEN

            if (l_distributed_from = 'GROUP_OWNED') THEN
	      l_grp_owner := p_WS_INPUT_DATA(j).OWNER_ID;
	    else
	      l_grp_owner := p_WS_INPUT_DATA(j).ASSIGNEE_ID;
            end if;

            l_task_distributed_to := p_resource_id;

            begin
              select 'X' into l_group_id
              from jtf_rs_group_members
              where resource_id = p_resource_id
                and group_id = l_grp_owner
                and nvl(delete_flag, 'N') = 'N'
                and rownum < 2;
            exception when no_data_found then
	      x_return_status := 'E';
            end;

--insert into rm_tmp values (null,null,'DISTRIBUTE_SRTASKS: After jtf_rs_group_members,x_return_status='||x_return_status,rm_tmp_seq.nextval);
--commit;
            if l_group_id = 'X' then

              if l_dist_st_based_on_parent_flag = 'Y' then

              -- Code changes required. This will be required only for 'Association' work
	      -- source like SR-TASK. The object code should be selected from
	      -- ieu_uwqm_work_sources_b for parent work source

                -- if p_ws_input_data(j).source_object_type_code = 'SR'  then
                l_source_object_code := p_ws_input_data(j).source_object_type_code;
                l_source_object_id := p_ws_input_data(j).source_object_id;

--insert into rm_tmp values (null,null,'DISTRIBUTE_SRTASKS: source_object_type_code=SR,l_source_object_id'||l_source_object_id||',l_source_object_code='||l_source_object_code,rm_tmp_seq.nextval);
--commit;
                begin
                  select distribution_status_id, status_id
		  into l_distribution_status, l_status_id
                  from ieu_uwqm_items
                  where workitem_pk_id = l_source_object_id
                    and workitem_obj_code = l_source_object_code;
                exception when no_data_found then
		  l_distribution_status := 0;
                end;
                -- end if;

              end if;

	      -- distribution_status 3 is Distributed, Status id 3 is Close.
              if ( ((l_distribution_status = 3 OR l_status_id = 3)
		     and l_dist_st_based_on_parent_flag = 'Y')
                  OR (l_dist_st_based_on_parent_flag is null) ) then

--insert into rm_tmp values (null,null,'DISTRIBUTE_SRTASKS: l_distribution_status=3',rm_tmp_seq.nextval);
--commit;

            	-- Update the SR Task Owner
		-- The update to the SR Task work item will be handled by
		-- rule function for the work source.

	        OPEN sel_tasks_csr(p_ws_input_data(j).workitem_pk_id);
		FETCH sel_tasks_csr INTO sel_tasks_rec;

		IF sel_tasks_csr%NOTFOUND THEN
		  x_return_status := 'E';
		ELSE

		  -- obtain the owner_type_code by concatenating 'RS_' and the category
		  -- from jtf_rs_resource_extns
		  OPEN sel_jtf_category_csr(P_RESOURCE_ID);
		  FETCH sel_jtf_category_csr INTO l_category;
		  IF (sel_jtf_category_csr%NOTFOUND) THEN
		    l_category := 'RS_EMPLOYEE';
		  END IF;
		  CLOSE sel_jtf_category_csr;


		  JTF_TASKS_PVT.UPDATE_TASK(
                        p_api_version           => 1.0,
                	p_commit		=> FND_API.G_TRUE,
                        p_object_version_number => sel_tasks_rec.object_version_number,
                        p_task_id               => sel_tasks_rec.task_id,
			--p_owner_type_code	=> 'RS_INDIVIDUAL',
			p_owner_type_code	=> l_category,
			p_owner_id		=> P_RESOURCE_ID,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data);


                  x_return_status := l_return_status;
		END IF;
		CLOSE sel_tasks_csr;


              end if;	-- if (l_distribution_status = 3 and l_dist_st_based_on_parent_flag = 'Y')

            end if;	-- if l_group_id = 'X'

          end if;	-- IF (p_WS_INPUT_DATA(j).Work_source = 'SR_TASKS')

          If x_return_status = 'S' THEN
              P_WS_INPUT_DATA(j).DISTRIBUTED := 'TRUE';
              P_WS_INPUT_DATA(j).ASSIGNEE_ID := p_resource_id;
              P_WS_INPUT_DATA(j).ASSIGNEE_TYPE := 'RS_INDIVIDUAL';
              P_WS_INPUT_DATA(j).ITEM_INCLUDED_BY_APP := 'FALSE';
          Else
              P_WS_INPUT_DATA(j).DISTRIBUTED := 'FALSE';
          End if;

        End loop;	-- For j in p_WS_INPUT_DATA .first.. p_WS_INPUT_DATA.last

      End if;		-- if (P_DIST_BUS_RULES(i).work_source = 'SR_TASKS')

    End loop;	-- For i  in P_DIST_BUS_RULES.first.. P_DIST_BUS_RULES.last


 END DISTRIBUTE_SRTASKS;


END CS_UWQ_DISTRIBUTE_ITEMS;

/
