--------------------------------------------------------
--  DDL for Package Body CS_WF_EVENT_SUBSCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WF_EVENT_SUBSCRIPTIONS_PKG" AS
/* $Header: csxevtsb.pls 120.2.12010000.2 2008/08/29 07:02:22 vpremach ship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- VPREMACH    08/28/08  Bug 7118071 : When task is created in close status,
--                       upward propagation has to work.
   -- Enter procedure, function bodies as shown below


  FUNCTION CS_SR_Verify_All(p_subscription_guid in raw,
                            p_event in out nocopy WF_EVENT_T) RETURN varchar2 is


-- Task Related Event Parameters and Cursors
    l_task_id       NUMBER;
    l_task_audit_id NUMBER;

   CURSOR c_sr_task_sr_closure_csr IS
    SELECT source_object_type_code,
           source_object_id ,
           open_flag ,
           last_updated_by,
           last_update_login
      FROM jtf_tasks_b
     WHERE task_id = l_task_id;

   c_sr_task_sr_closure_rec   c_sr_task_sr_closure_csr%ROWTYPE;

-- Get the status details from the SR task audit record

   CURSOR c_sr_task_status_audit IS
    SELECT old_task_status_id ,
           new_task_status_id,
           last_updated_by
      FROM jtf_task_audits_b
     WHERE task_id = l_task_id
       AND task_audit_id = l_task_audit_id ;

   c_sr_task_status_audit_rec  c_sr_task_status_audit%ROWTYPE;

-- Generic Event Parameters and Cursors
    l_event_name         VARCHAR2(240) := p_event.getEventName( );
    l_request_id         NUMBER := NULL;
    l_resp_appl_id       NUMBER := NULL;
    l_login_id           NUMBER := NULL;
    l_user_id            NUMBER := NULL;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_auto_close_profile VARCHAR2(30);
    l_status_prop_flag   VARCHAR2(3) := 'N' ;

BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_PROFILE.GET('CS_SR_AUTO_CLOSE_SR',l_auto_close_profile);

    IF nvl(l_auto_close_profile, 'NO') <> 'YES' THEN
       return 'SUCCESS';
    END IF;

    --Begin Bug 7118071
      IF (l_event_name = 'oracle.apps.jtf.cac.task.createTask') THEN
       l_task_id       := p_event.GetValueForParameter('TASK_ID');

       OPEN c_sr_task_sr_closure_csr;
       FETCH c_sr_task_sr_closure_csr INTO c_sr_task_sr_closure_rec;
       CLOSE c_sr_task_sr_closure_csr;

       IF (  c_sr_task_sr_closure_rec.source_object_type_code <> 'SR') THEN
  	   return 'SUCCESS';
       END IF;
       IF (NVL(c_sr_task_sr_closure_rec.open_flag ,'X') = 'N') THEN
             l_status_prop_flag := 'Y';
             l_request_id       :=  c_sr_task_sr_closure_rec.source_object_id;
             l_user_id          := NVL(c_sr_task_sr_closure_rec.last_updated_by,FND_GLOBAL.USER_ID);
             l_resp_appl_id     :=  FND_GLOBAL.RESP_APPL_ID;
             l_login_id         := NVL(c_sr_task_sr_closure_rec.last_update_login,FND_GLOBAL.LOGIN_ID) ;
       END IF;
     END IF;
    --End Bug 7118071

    ---- Code to handle update to SR task status

    IF (l_event_name = 'oracle.apps.jtf.cac.task.updateTask') THEN

       l_task_id       := p_event.GetValueForParameter('TASK_ID');
       l_task_audit_id := p_event.GetValueForParameter('TASK_AUDIT_ID');

        OPEN c_sr_task_sr_closure_csr;
        FETCH c_sr_task_sr_closure_csr INTO c_sr_task_sr_closure_rec;
        CLOSE c_sr_task_sr_closure_csr;

        IF (  c_sr_task_sr_closure_rec.source_object_type_code <> 'SR') THEN
           return 'SUCCESS';
        END IF;

       IF (NVL(c_sr_task_sr_closure_rec.open_flag ,'X') = 'N') THEN

           OPEN c_sr_task_status_audit ;
          FETCH c_sr_task_status_audit INTO c_sr_task_status_audit_rec;
          CLOSE c_sr_task_status_audit ;

          IF (c_sr_task_status_audit_rec.new_task_status_id <> c_sr_task_status_audit_rec.old_task_status_id) THEN

             l_status_prop_flag := 'Y';
             l_request_id       :=  c_sr_task_sr_closure_rec.source_object_id;
             l_user_id          := NVL(c_sr_task_sr_closure_rec.last_updated_by,FND_GLOBAL.USER_ID);
             l_resp_appl_id     :=  FND_GLOBAL.RESP_APPL_ID;
             l_login_id         := NVL(c_sr_task_sr_closure_rec.last_update_login,FND_GLOBAL.LOGIN_ID) ;
          END IF ;
       END IF ;
    END IF;

    ---- Code to handle charge lines
    IF (l_event_name = 'oracle.apps.cs.chg.Charges.submitted') THEN

        l_status_prop_flag := 'Y';
        l_request_id       :=  p_event.GetValueForParameter('INCIDENT_ID');
        l_user_id          := p_event.GetValueForParameter('USER_ID');
        l_resp_appl_id     := p_event.GetValueForParameter('RESP_APPL_ID');
        l_login_id         := FND_GLOBAL.LOGIN_ID;

    END IF;

    IF l_status_prop_flag = 'Y' THEN

       CS_SR_STATUS_PROPAGATION_PKG.SR_UPWARD_STATUS_PROPAGATION(
                      p_api_version        => 1.0,
                      p_service_request_id => l_request_id,
                      p_user_id            => l_user_id,
                      p_resp_appl_id       => l_resp_appl_id,
                      p_login_id           => l_login_id,
                      x_return_status      => l_return_status,
                      x_msg_count          => l_msg_count,
                      x_msg_data           => l_msg_data);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--           RAISE FND_API.G_EXC_ERROR ;
          return 'SUCCESS';
       END IF;
    END IF ;

    return 'SUCCESS';

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         return 'ERROR';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         return 'ERROR';

    WHEN OTHERS THEN
         return 'ERROR';

END CS_SR_Verify_All;

/*
    This business event subscription notifies the task owner and/or task assignee,
    if conditions are met, when assigned non-field service tasks are Cancelled/Rejected

    The conditions are :
    1) The event that triggered this subscription should be "updateTask" event
    2) The state restrictions profile option "CS_SR_TASK_STATE_ENABLED" should be set to value "Yes"
    3) The task that got cancelled/rejected should be non-field service task
    4) The non-field service task was in assigned state when it was cancelled/rejected
*/
FUNCTION CS_SR_SendNtf_To_NonFS_Task(p_subscription_guid in raw,
                                     p_event in out nocopy WF_EVENT_T) RETURN varchar2 is

-- Generic Event Parameters and Cursors
    l_event_name 	VARCHAR2(240) := p_event.getEventName( );

     l_task_audit_id NUMBER;
     l_task_id NUMBER;
     l_task_status_id NUMBER;
     l_task_owner_id NUMBER;
     l_task_assignee_id NUMBER;
     l_task_resource_id NUMBER;
     l_nid NUMBER;

     l_state_restrictions_on  VARCHAR2(3);
     l_tasktype_rule VARCHAR2(30);
     l_task_status VARCHAR2(30);
     l_owner_role                VARCHAR2(320);
     l_owner_name                VARCHAR2(240);

    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);


    CURSOR cs_sr_oldnew_task_status_csr IS
      SELECT old_task_status_id, new_task_status_id
      FROM JTF_TASK_AUDITS_VL
      WHERE task_audit_id = l_task_audit_id;

   cs_sr_oldnew_task_status_rec cs_sr_oldnew_task_status_csr%ROWTYPE;


   CURSOR cs_sr_get_status_flags_csr IS
      SELECT assigned_flag, cancelled_flag, rejected_flag, start_date_type, end_date_type, name
        FROM JTF_TASK_STATUSES_VL
        WHERE task_status_id = l_task_status_id;

   cs_sr_get_status_flags_rec cs_sr_get_status_flags_csr%ROWTYPE;

   CURSOR cs_sr_check_nonFS_type_csr IS
	  SELECT b.rule, a.task_name, a.description, a.task_number
	    FROM JTF_TASKS_VL a,
	         JTF_TASK_TYPES_B b
	    WHERE a.task_type_id = b.task_type_id
	      AND a.task_id = l_task_id;

   cs_sr_check_nonFS_type_rec cs_sr_check_nonFS_type_csr%ROWTYPE;

/* The following 2 cursors will get the task resource information required to send WF notifications */
  CURSOR cs_sr_get_task_assignee_id_csr IS
    SELECT b.source_id
	FROM jtf_task_assignments a, jtf_rs_resource_extns b
	WHERE a.resource_id = b.resource_id(+) AND
   	      a.task_id = l_task_id;

  CURSOR cs_sr_get_task_owner_id_csr IS
    SELECT b.source_id
	FROM jtf_tasks_b a, jtf_rs_resource_extns b
	WHERE a.owner_id = b.resource_id(+) AND
   	      a.task_id = l_task_id;

BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get the value currently held by the "Service: Apply State Restrictions on Tasks" profile option
    l_state_restrictions_on := FND_PROFILE.VALUE('CS_SR_ENABLE_TASK_STATE_RESTRICTIONS');

    --INSERT into cs_tmp1 values ('l_state_restrictions_on = ' || l_state_restrictions_on);

    /*
    We want to sent error notification to the task owner and/or task assignee
    only if :

    1) Task update has occurred
    2) An assigned non-field service task is cancelled/rejected
    3) State restrictions are enforced

    */
    IF (l_state_restrictions_on = 'Y' AND
	l_event_name = 'oracle.apps.jtf.cac.task.updateTask') THEN


      l_task_id := p_event.GetValueForParameter('TASK_ID');
      l_task_audit_id := p_event.GetValueForParameter('TASK_AUDIT_ID');


      OPEN cs_sr_check_nonFS_type_csr;
      FETCH cs_sr_check_nonFS_type_csr into cs_sr_check_nonFS_type_rec;
      CLOSE cs_sr_check_nonFS_type_csr;

      /* Ensure the task is non-field service task */
      IF( cs_sr_check_nonFS_type_rec.rule is null OR
	  (cs_sr_check_nonFS_type_rec.rule is not null AND cs_sr_check_nonFS_type_rec.rule <> 'DISPATCH') ) THEN


        --l_task_id := p_event.GetValueForParameter('TASK_ID');
        --l_task_audit_id := p_event.GetValueForParameter('TASK_AUDIT_ID');


        OPEN cs_sr_oldnew_task_status_csr;
        FETCH cs_sr_oldnew_task_status_csr INTO cs_sr_oldnew_task_status_rec;
        CLOSE cs_sr_oldnew_task_status_csr;

        /* If both old and new status id's are the same, no need to proceed any further */
	IF (cs_sr_oldnew_task_status_rec.old_task_status_id <> cs_sr_oldnew_task_status_rec.new_task_status_id) THEN


	  l_task_status_id := cs_sr_oldnew_task_status_rec.new_task_status_id;
	  OPEN cs_sr_get_status_flags_csr;
	  FETCH cs_sr_get_status_flags_csr INTO cs_sr_get_status_flags_rec;
	  CLOSE cs_sr_get_status_flags_csr;

          /* First check if the current task was cancelled/rejected. Else, the subscription can exit right away */
	  IF(nvl(cs_sr_get_status_flags_rec.cancelled_flag,' ') = 'Y' OR
	     nvl(cs_sr_get_status_flags_rec.rejected_flag,' ') = 'Y') THEN


	    l_task_status := cs_sr_get_status_flags_rec.name;

	    l_task_status_id := cs_sr_oldnew_task_status_rec.old_task_status_id;
    	    OPEN cs_sr_get_status_flags_csr;
	    FETCH cs_sr_get_status_flags_csr INTO cs_sr_get_status_flags_rec;
	    CLOSE cs_sr_get_status_flags_csr;

	    /* Now check if the previous task status was "Assigned" status.
	       If yes, we need to send notifications to task owner and/or task assignee
	    */
	    IF(nvl(cs_sr_get_status_flags_rec.assigned_flag,' ') = 'Y'  --AND
		      -- nvl(cs_sr_get_status_flags_rec.start_date_type, ' ') = 'SCHEDULED_START' AND
		      -- nvl(cs_sr_get_status_flags_rec.end_date_type, ' ') = 'SCHEDULED_END'
	      ) THEN


	      /* Send WF notifications to task owner.. */
   	      OPEN cs_sr_get_task_owner_id_csr;
   	      FETCH cs_sr_get_task_owner_id_csr INTO l_task_owner_id;
   	      CLOSE cs_sr_get_task_owner_id_csr;

   	      IF(l_task_owner_id is not null) THEN


	        CS_WORKFLOW_PUB.Get_Employee_Role (
                    p_api_version           =>  1.0,
                    p_return_status         =>  l_return_status,
                    p_msg_count             =>  l_msg_count,
                    p_msg_data              =>  l_msg_data,
                    p_employee_id           =>  l_task_owner_id,
                    p_role_name             =>  l_owner_role,
                    p_role_display_name     =>  l_owner_name );

	        IF (l_owner_role IS NOT NULL) THEN


          	    l_nid := WF_NOTIFICATION.Send(role => l_owner_role,
					            msg_type => 'SERVEREQ',
						    msg_name => 'CS_SR_NOTIFY_TASK_RESOURCES');

                  WF_NOTIFICATION.setattrtext(l_nid,'TASK_NUMBER',cs_sr_check_nonFS_type_rec.task_number);
                  WF_NOTIFICATION.setattrtext(l_nid,'TASK_NAME',cs_sr_check_nonFS_type_rec.task_name);
                  WF_NOTIFICATION.setattrtext(l_nid,'TASK_DESCRIPTION',cs_sr_check_nonFS_type_rec.description);
                  WF_NOTIFICATION.setattrtext(l_nid,'TASK_RESOURCE_NAME',l_owner_name);
                  WF_NOTIFICATION.setattrtext(l_nid,'ASSOCIATION_TYPE','owned by ');
		  WF_NOTIFICATION.setattrtext(l_nid,'TASK_STATUS',l_task_status);

		  Wf_Notification.Denormalize_Notification(l_nid);

		END IF;

              END IF ; -- End of 	IF(l_task_owner_id is not null)


     	      OPEN cs_sr_get_task_assignee_id_csr;
	      LOOP

	        FETCH cs_sr_get_task_assignee_id_csr INTO l_task_assignee_id;
	   	EXIT WHEN cs_sr_get_task_assignee_id_csr%NOTFOUND;

   		IF(l_task_assignee_id is not null) THEN


	    	  CS_WORKFLOW_PUB.Get_Employee_Role (
                    p_api_version           =>  1.0,
                    p_return_status         =>  l_return_status,
                    p_msg_count             =>  l_msg_count,
                    p_msg_data              =>  l_msg_data,
                    p_employee_id           =>  l_task_assignee_id,
                    p_role_name             =>  l_owner_role,
                    p_role_display_name     =>  l_owner_name );

	   	  IF (l_owner_role IS NOT NULL) THEN


          	    l_nid := WF_NOTIFICATION.Send(role => l_owner_role,
						  msg_type => 'SERVEREQ',
						  msg_name => 'CS_SR_NOTIFY_TASK_RESOURCES');
                    WF_NOTIFICATION.setattrtext(l_nid,'TASK_NUMBER',cs_sr_check_nonFS_type_rec.task_number);
                    WF_NOTIFICATION.setattrtext(l_nid,'TASK_NAME',cs_sr_check_nonFS_type_rec.task_name);
                    WF_NOTIFICATION.setattrtext(l_nid,'TASK_DESCRIPTION',cs_sr_check_nonFS_type_rec.description);
                    WF_NOTIFICATION.setattrtext(l_nid,'TASK_RESOURCE_NAME',l_owner_name);
                    WF_NOTIFICATION.setattrtext(l_nid,'ASSOCIATION_TYPE','assigned to ');
		    WF_NOTIFICATION.setattrtext(l_nid,'TASK_STATUS',l_task_status);

		    Wf_Notification.Denormalize_Notification(l_nid);

		  END IF;

		END IF; /* end of IF(l_task_assignee_id is not null)  */


	      END LOOP;
	      CLOSE cs_sr_get_task_assignee_id_csr;



	    END IF; -- End of IF(nvl(cs_sr_get_status_flags_rec.assigned_flag,' ') = 'Y' ....

	  END IF;	-- End of IF(nvl(cs_sr_get_status_flags_rec.cancelled_flag,' ') = 'Y' ....

	END IF;  -- End of IF (cs_sr_oldnew_task_status_rec.old_task_status_id ....

      END IF ; -- End of IF(l_tasktype_rule is not null)

    END IF;   -- End of IF (l_state_restrictions_on = 'Y' AND l_event_name = 'oracle.apps.jtf.cac.task.updateTask')

    return 'SUCCESS';

  EXCEPTION

    WHEN OTHERS THEN
      return 'WARNING';

END CS_SR_SendNtf_To_NonFS_Task;


   -- Enter further code below as specified in the Package spec.
END; -- Package Body CS_WF_EVENT_SUBSCRIPTIONS_PKG

/
