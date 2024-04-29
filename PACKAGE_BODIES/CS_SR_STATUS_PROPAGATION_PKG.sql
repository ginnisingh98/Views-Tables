--------------------------------------------------------
--  DDL for Package Body CS_SR_STATUS_PROPAGATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_STATUS_PROPAGATION_PKG" AS
/* $Header: csxsrspb.pls 120.2 2006/04/12 13:56:26 jngeorge ship $ */


  G_PKG_NAME VARCHAR2(30) := 'CS_SR_STATUS_PROPAGATION_PKG';
  PROCEDURE VALIDATE_SR_CLOSURE(
	      p_api_version   	   IN         NUMBER,
	      p_init_msg_list	   IN         VARCHAR2 DEFAULT fnd_api.g_false,
	      p_commit		   IN         VARCHAR2,
              p_service_request_id IN         NUMBER,
              p_user_id            IN         NUMBER,
              p_resp_appl_id       IN         NUMBER,
              p_login_id           IN         NUMBER DEFAULT NULL,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2
	      )  IS


    l_task_id NUMBER;
    l_inc_id NUMBER;
    l_api_name VARCHAR2(30) := 'Validate_SR_Closure';
    l_return_status  VARCHAR2(3);
    l_func_ret_status  BOOLEAN;
    l_msg_count    NUMBER;
    l_msg_data   VARCHAR2(2000);

    CS_UNSUBMITTED_CHARGES_EXIST exception;
    CS_OPEN_TASKS_EXIST  exception;

    CURSOR c_charge_lines IS
      SELECT incident_id
        FROM CS_ESTIMATE_DETAILS
        WHERE incident_id = p_service_request_id
	  AND (charge_line_type = 'IN_PROGRESS'
            OR (charge_line_type='ACTUAL'
	        AND interface_to_oe_flag = 'Y'
	        AND order_line_id is null));

	CURSOR c_OpenTasks IS
	  SELECT a.task_id,
                 a.source_object_id ,
	         --b.closed_flag,
                 a.open_flag,
	         --b.completed_flag,
	         a.scheduled_start_date,
	         a.scheduled_end_date,
	         a.actual_start_date,
	         a.actual_end_date,
	         c.rule
	    FROM JTF_TASKS_B a,
	         --JTF_TASK_STATUSES_B b,
	         JTF_TASK_TYPES_B c
	    WHERE a.task_type_id = c.task_type_id
	     --a.task_status_id = b.task_status_id
	      AND a.source_object_type_code = 'SR'
	      AND a.source_object_id = p_service_request_id;

    BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* Check if child is a charge line with charge_line_type = 'Actual'
         and OM interface flag = 'Y' and charge line is not yet submitted
         to OM */

      OPEN c_charge_lines;
      fetch c_charge_lines into l_inc_id;

      IF(c_charge_lines%FOUND) THEN
        raise CS_UNSUBMITTED_CHARGES_EXIST;
      END IF;
      CLOSE c_charge_lines;



      For sr_tasks in c_OpenTasks LOOP

	/* check if the child is :
           *) Field Service task  AND (if not, the FS api should return success)
	*/
	IF(sr_tasks.rule = 'DISPATCH') THEN

--	   Invoke Field Service API

         l_func_ret_status := CSF_TASKS_PUB.task_is_closable
	                     ( p_task_id => sr_tasks.task_id,
	                       x_return_status => l_return_status,
	                       x_msg_count  => l_msg_count,
	                       x_msg_data  => l_msg_data);

          IF (l_func_ret_status = FALSE) THEN
             raise FND_API.G_EXC_ERROR;
	  END IF;
	ELSE

	/* Check if child is an open non-field service task  */
	  --IF (nvl(sr_tasks.closed_flag,'N') <> 'Y') THEN
	    IF (nvl(sr_tasks.open_flag,'Y') <> 'N') THEN
	       IF (sr_tasks.actual_start_date is not null) THEN
	         IF (trunc(sr_tasks.actual_start_date) <= trunc(sysdate)
	           AND trunc(nvl(sr_tasks.actual_end_date,sysdate)) >=
                       trunc(sysdate))  THEN

                   raise CS_OPEN_TASKS_EXIST;

                 END IF;
               ELSE
	          IF (sr_tasks.scheduled_start_date is not null
	            AND (trunc(sr_tasks.scheduled_start_date) <= trunc(sysdate)
	            AND trunc(nvl(sr_tasks.scheduled_end_date,sysdate)) >=
                      trunc(sysdate))) THEN

                    raise CS_OPEN_TASKS_EXIST;

	          END IF;
	        END IF;
              END IF;
            END IF;
	  END LOOP;
      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                       p_data  => x_msg_data);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                       p_data  => x_msg_data);

         WHEN  CS_UNSUBMITTED_CHARGES_EXIST THEN
  	   x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('CS','CS_SR_OPEN_CHARGES_EXISTS');
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                       p_data  => x_msg_data);

         WHEN  CS_OPEN_TASKS_EXIST THEN
  	   x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('CS','CS_SR_OPEN_TASKS_EXISTS');
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                       p_data  => x_msg_data);
         WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
           END IF;
           FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                      p_data         => x_msg_data);
  END;

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -----------------------------------------------------------------------------
-- 05/10/05 smisra   Fixed bug 4211144
--                   changed the type of variable l_auto_Task_close_status from
--                   varchar2(3) to Number. Added another variable
--                   l_profile_value to get value of profile
--                   CS_SR_TASK_AUTO_CLOSE_STATUS and set
--                   l_auto_task_close_status using to_number of l_profile_value
--                   The above change was needed to avoid pl/sql numberic value
--                   Error. Called csf_tasks_pub.close_task using named natotion
-- 07/06/05 smisra   Fixed bug 4453777
--                   Changed the size of variable l_profile_value from
--                   varchar2 to varchar2(240)
-- -----------------------------------------------------------------------------
  PROCEDURE CLOSE_SR_CHILDREN(
	      p_api_version   	    IN         NUMBER,
	      p_init_msg_list       IN         VARCHAR2 DEFAULT fnd_api.g_false,
	      p_commit		    IN         VARCHAR2 DEFAULT fnd_api.g_false,
	      p_validation_required IN         VARCHAR2,
	      p_action_required     IN 	       VARCHAR2,
              p_service_request_id  IN         NUMBER,
              p_user_id             IN         NUMBER,
              p_resp_appl_id        IN         NUMBER,
              p_login_id            IN         NUMBER DEFAULT NULL,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2
	      )  IS


    CURSOR c_OpenTasks IS
      SELECT task.task_id,
             task.object_version_number,
             --status.closed_flag,
             task.open_flag,
             type.rule
	FROM JTF_TASKS_B task,
	     --JTF_TASK_STATUSES_B  status,
             JTF_TASK_TYPES_B type
	WHERE task.source_object_type_code = 'SR'
	  AND task.source_object_id = p_service_request_id
          AND task.task_type_id = type.task_type_id
          --AND task.task_status_id = status.task_status_id
	  --AND nvl(status.closed_flag,'N') = 'N';
	  AND nvl(task.open_flag,'Y') = 'Y';

    CURSOR c_sr_status IS
      SELECT status.close_flag
        FROM cs_incidents_all_B sr,
             cs_incident_statuses_b status
        WHERE sr.incident_id = p_service_request_id
          AND sr.incident_status_id = status.incident_status_id
          AND status.close_flag = 'Y';

    l_api_name VARCHAR2(30) := 'Close_SR_Children';

    l_status_flag            varchar2(3);
    l_profile_value          varchar2(240);
    l_auto_task_close_status NUMBER     ;
    l_return_status  VARCHAR2(3);

    BEGIN

      SAVEPOINT CLOSE_SR_CHILDREN;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- If the auto task close status is null, return immediately

      FND_PROFILE.GET('CS_SR_TASK_AUTO_CLOSE_STATUS',l_profile_value);

      IF  (l_profile_value is not null) THEN
      -- Invoke the validation API if validation_required = Y
        l_auto_task_close_status := to_number(l_profile_value);
        IF (p_validation_required = 'Y') THEN
          CS_SR_STATUS_PROPAGATION_PKG.VALIDATE_SR_CLOSURE(
   	                                 p_api_version,
	                                 p_init_msg_list,
	                                 p_commit,
                                         p_service_request_id,
                                         p_user_id ,
                                         p_resp_appl_id ,
                                         p_login_id ,
                                         l_return_status,
                                         x_msg_count,
                                         x_msg_data);

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     raise FND_API.G_EXC_ERROR;
	   END IF;
       END IF;

       -- Continue with the rest of the flow if action_required = Y
       if (p_action_required = 'Y') then

          -- Get all open tasks
          FOR sr_tasks in c_OpenTasks
            LOOP

              IF (sr_tasks.rule = 'DISPATCH') THEN
                --   Invoke Field Service action API();
--dbms_output.put_line('Found a FS task ');
                 CSF_TASKS_PUB.close_task
                 ( p_api_version   => 1.0
                 , p_init_msg_list => p_init_msg_list
                 , p_commit        => p_commit
                 , p_task_id       => sr_tasks.task_id
                 , x_return_status => l_return_status
                 , x_msg_count     => x_msg_count
                 , x_msg_data      => x_msg_data
                 );

	         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	           raise FND_API.G_EXC_UNEXPECTED_ERROR;
	         end if;
               ELSE

               /*
	          Call update_task() API to update the task status to the
                  status value held in the Service: Task Auto Close Status
                  profile option
               */

--dbms_output.put_line('Found a NFS task ');

                 JTF_TASKS_PUB.update_task(
	                                p_api_version => 1.0,
	                                p_init_msg_list => p_init_msg_list,
	                                p_commit => p_commit,
                                        p_object_version_number => sr_tasks.object_version_number,
                                        p_task_id => sr_tasks.task_id,
                                        p_task_status_id => l_auto_task_close_status,
                                        x_return_status => l_return_status,
                                        x_msg_count => x_msg_count,
                                        x_msg_data => x_msg_data
                                       );

 	         -- If update_task() API returned error, raise an exception

	         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	           raise FND_API.G_EXC_UNEXPECTED_ERROR;
	         end if;
   	       END IF;
             END LOOP;
	   END IF;
         END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CLOSE_SR_CHILDREN;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CLOSE_SR_CHILDREN;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
      WHEN OTHERS THEN
        ROLLBACK TO CLOSE_SR_CHILDREN;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                   p_data         => x_msg_data);

    END;


  PROCEDURE SR_UPWARD_STATUS_PROPAGATION(
	      p_api_version   	   IN         NUMBER,
	      p_init_msg_list	   IN         VARCHAR2 DEFAULT fnd_api.g_false,
	      p_commit		   IN         VARCHAR2 DEFAULT fnd_api.g_false,
              p_service_request_id IN         NUMBER,
              p_user_id            IN         NUMBER,
              p_resp_appl_id       IN         NUMBER,
              p_login_id           IN         NUMBER DEFAULT NULL,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2
	      )  IS

    l_task_id NUMBER;
    l_status_id NUMBER;
    l_child_id NUMBER;
    l_resp_id NUMBER;
    l_interaction_id NUMBER;
    l_object_version_number  NUMBER;
    l_close_date  DATE;
    l_sr_status  NUMBER;
    l_api_name VARCHAR2(30) := 'SR_Upward_Status_Propagation';
    l_return_status  VARCHAR2(3);
    l_msg_count    NUMBER;
    l_msg_data   VARCHAR2(2000);

    CS_UNSUBMITTED_CHARGES_EXIST exception;
    CS_OPEN_TASKS_EXIST  exception;
    CS_DEPOT_ORDERS_EXIST exception;
    CS_CMRO_ORDERS_EXIST exception;
    CS_EAM_ORDERS_EXIST exception;

    CURSOR c_status(c_request_id number) IS
      SELECT incident_status_id
        FROM cs_incidents_all_b
        WHERE incident_id = c_request_id;

    CURSOR c_charge_lines IS
      SELECT incident_id
        FROM CS_ESTIMATE_DETAILS
        WHERE incident_id = p_service_request_id
	  AND (charge_line_type = 'IN_PROGRESS'
            OR (charge_line_type='ACTUAL'
	        AND interface_to_oe_flag = 'Y'
	        AND order_line_id is null));

	CURSOR c_open_tasks IS
	  SELECT tasks.task_id
	    FROM JTF_TASKS_B tasks
	         --JTF_TASK_STATUSES_B status
	    WHERE tasks.source_object_type_code  = 'SR'
	      AND tasks.source_object_id         = p_service_request_id
	      --AND tasks.task_status_id           = status.task_status_id
	      --AND nvl(status.closed_flag,'N')    = 'N';
	      AND nvl(tasks.open_flag,'Y')    = 'Y';

     CURSOR c_depot_orders IS
       SELECT REPAIR_LINE_ID
         FROM csd_repairs
         WHERE incident_id = p_service_request_id;

     CURSOR c_eam_orders IS
       SELECT wip_entity_id
         FROM eam_wo_service_association
         WHERE service_request_id = p_service_request_id;

     CURSOR c_cmro_orders IS
       SELECT ue.mr_header_id
         FROM ahl_unit_effectivities_app_v sr_ue,
              ahl_unit_effectivities_app_v ue,
              ahl_ue_relationships uer
         WHERE sr_ue.unit_effectivity_id = uer.ue_id
           and uer.related_ue_id = ue.unit_effectivity_id
           and sr_ue.cs_incident_id = p_service_request_id;
     CURSOR c_obj_ver_num IS
       Select object_version_number
         FROM cs_incidents_all_b
         WHERE incident_id = p_service_request_id;


/* ROOPA - 12/02/2003 - Begin*/
/* This block of code takes care of the exception path for upward status propagation */
    CURSOR l_cs_sr_get_empid_csr IS
      SELECT inc.incident_number, emp.source_id
      FROM jtf_rs_resource_extns emp ,
           cs_incidents_all_b inc
      WHERE emp.resource_id = inc.incident_owner_id
        AND inc.incident_id = p_service_request_id;

    l_subject_owner_id		NUMBER;
    l_notification_id   NUMBER;

    l_owner_role        VARCHAR2(100);
    l_owner_name        VARCHAR2(240);
    l_request_number    	VARCHAR2(64);
/* ROOPA - 12/02/2003 - End */

    BEGIN

      SAVEPOINT SR_UPWARD_STATUS_PROPAGATION;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      open c_status(p_service_request_id);
      fetch c_status into l_sr_status;
      IF (c_status%NOTFOUND) THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- If all the above conditions are satisfied, update SR status
      -- to 'Close' status. This status is derived fromt the profile
      -- 'Service : Service Request Auto Close Status'
      -- (Internal Name - CS_SR_AUTO_CLOSE_STATUS')

      FND_PROFILE.GET('CS_SR_AUTO_CLOSE_STATUS',l_status_id);

      IF (l_status_id IS NOT NULL and l_status_id <> l_sr_status) THEN
        open c_depot_orders;
        fetch c_depot_orders into l_child_id;
        IF(c_depot_orders%FOUND) THEN
          raise CS_DEPOT_ORDERS_EXIST;
        END IF;

        open c_eam_orders;
        fetch c_eam_orders into l_child_id;
        IF(c_eam_orders%FOUND) THEN
          raise CS_EAM_ORDERS_EXIST;
        END IF;

        open c_cmro_orders;
        fetch c_cmro_orders into l_child_id;
        IF(c_cmro_orders%FOUND) THEN
          raise CS_CMRO_ORDERS_EXIST;
        END IF;

        -- Check if child is a charge line with charge_line_type = 'Actual'
        -- and OM interface flag = 'Y' and charge line is not yet submitted
        -- to OM


        open c_charge_lines;
        fetch c_charge_lines into l_child_id;
        IF(c_charge_lines%FOUND) THEN
          raise CS_UNSUBMITTED_CHARGES_EXIST;
        END IF;

        open c_open_tasks;
        fetch c_open_tasks into l_child_id;
        IF(c_open_tasks%FOUND) THEN
          raise CS_OPEN_TASKS_EXIST;
        END IF;

    --      IF (l_close_flag = 'Y') THEN
    --        l_closed_date := sysdate;
    --      ELSE
    --        l_closed_date := NULL;
   --       END IF;

        open c_obj_ver_num;
        fetch c_obj_ver_num into l_object_version_number;
        close c_obj_ver_num;

        l_resp_id := fnd_global.resp_id;

         CS_ServiceRequest_PVT.Update_Status
           ( p_api_version          => 2.0,
             p_init_msg_list        => p_init_msg_list,
             p_commit               => p_commit,
             p_resp_id              => l_resp_id,
             p_validation_level     => fnd_api.g_valid_level_none,
             x_return_status        => x_return_status,
             x_msg_count            => x_msg_count,
             x_msg_data             => x_msg_data,
             p_request_id           => p_service_request_id,
             p_status_id            => l_status_id,
           --  p_closed_date          => l_close_date,
             p_object_version_number => l_object_version_number,
             p_last_updated_by      => p_user_id,
             p_last_update_date     => sysdate,
             x_interaction_id       => l_interaction_id);



/* ROOPA - 12/02/2003 - Begin*/
/* This block of code takes care of the exception path for upward status propagation */
/* Logic
   ------
   1) Get the current service request's owner
   2) Get the WF role associated to the current service request's owner
   3) If a WF role exists,
        -- Set the required WF message attributes
        -- Invoke WF_NOTIFICATION.Send() API to send an independent notificatiom
            to the service request owner
*/
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    OPEN l_cs_sr_get_empid_csr;
	FETCH l_cs_sr_get_empid_csr	INTO l_request_number, l_subject_owner_id;

	IF( l_cs_sr_get_empid_csr%NOTFOUND OR l_subject_owner_id IS NULL) THEN
	  l_owner_role := NULL;
    ELSE
	  -- Retrieve the role name for the request owner
          CS_WORKFLOW_PUB.Get_Employee_Role (
                    p_api_version           =>  1.0,
                    p_return_status         =>  l_return_status,
                    p_msg_count             =>  l_msg_count,
                    p_msg_data              =>  l_msg_data,
                    p_employee_id           =>  l_subject_owner_id,
                    p_role_name             =>  l_owner_role,
                    p_role_display_name     =>  l_owner_name );
	END IF;
	CLOSE l_cs_sr_get_empid_csr;


    If (l_owner_role IS NOT NULL) THEN

      l_notification_id := WF_Notification.Send(
                        role            =>  l_owner_role,
                        msg_type        =>  'SERVEREQ',
                        msg_name        =>  'CS_SR_NTFY_OWNER_UPDATE_FAILED');

      WF_Notification.SetAttrText(
                        nid             =>  l_notification_id,
                        aname           =>  'UPDATE_ERROR_DATA',
                        avalue          =>  l_msg_data);


      WF_Notification.SetAttrText(
                        nid             =>  l_notification_id,
                        aname           =>  'UPDATE_REQUEST_NUMBER',
                        avalue          =>  l_request_number);


      WF_NOTIFICATION.SetAttrText(
                        nid             =>      l_notification_id,
                        aname           =>      '#FROM_ROLE',
                        avalue          =>      l_owner_role);


      END IF; /*     If (l_owner_role IS NOT NULL) */
     END IF; /* IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) */
/* ROOPA - 12/02/2003 - End*/



      END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
      WHEN  CS_DEPOT_ORDERS_EXIST THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
  	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_SR_EAM_ORDERS_EXIST');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data);
      WHEN  CS_EAM_ORDERS_EXIST THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
  	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_SR_CMRO_ORDERS_EXIST');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data);
      WHEN  CS_CMRO_ORDERS_EXIST THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
  	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_SR_CMRO_ORDERS_EXIST');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data);
      WHEN  CS_UNSUBMITTED_CHARGES_EXIST THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
  	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_SR_OPEN_CHARGES_EXISTS');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data);
      WHEN  CS_OPEN_TASKS_EXIST THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
  	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_SR_OPEN_TASKS_EXIST');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data);
      WHEN OTHERS THEN
        ROLLBACK TO SR_UPWARD_STATUS_PROPAGATION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                   p_data         => x_msg_data,
                                   p_encoded      => FND_API.G_FALSE );
  END;

  END CS_SR_STATUS_PROPAGATION_PKG;

/
