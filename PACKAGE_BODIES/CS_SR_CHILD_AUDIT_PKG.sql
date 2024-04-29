--------------------------------------------------------
--  DDL for Package Body CS_SR_CHILD_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_CHILD_AUDIT_PKG" AS
/* $Header: cssraudb.pls 120.5.12010000.3 2008/09/25 17:11:16 bkanimoz ship $*/


/***************
Custom Function corrsponds to the business events published by SR child entities.
This custom function will be called from the subscriptions of the update/create/delete events for the
following SR child entities.
1. SR Tasks
2. SR Notes
3. SR Solution Links.
4. SR Task Assignments

***************/

-- Added for status update --anmukher -- 10/16/03
FUNCTION GET_STATUS_FLAG( p_incident_status_id IN  NUMBER)
   RETURN VARCHAR2;

FUNCTION CS_SR_Audit_ChildEntities
                (P_subscription_guid  IN RAW,
                 P_event              IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2 IS

 l_event_key              NUMBER ;
 l_event_name 	          VARCHAR2(240) := p_event.getEventName();
 l_updated_entity_code    VARCHAR2(40) ;
 l_updated_entity_id      NUMBER;
 l_entity_update_date     DATE ;
 l_entity_activity_code   VARCHAR2(30) ;
 l_source_object_code     VARCHAR2(240);
 l_source_object_id       NUMBER ;
 l_incident_id            NUMBER ;
 l_user_id                NUMBER := null ;
 l_audit_id		  NUMBER ;
 l_return_status 	  VARCHAR2(30);
 l_msg_count 	 	  NUMBER ;
 l_msg_data   	 	  VARCHAR2(2000) ;

 -- Cursors to get Task Details

    CURSOR get_Task_Dtls (p_task_id IN NUMBER) IS
           SELECT task_id ,
                  last_update_date,
                  creation_date ,
                  last_updated_by,
                  source_object_type_code ,
                  source_object_id
            FROM jtf_tasks_vl
           WHERE task_id = p_task_id ;

 -- Cursor to get Task Assignment Details

    CURSOR get_TaskAssign_dtls (p_task_assignment_id IN NUMBER) IS
           SELECT task_assignment_id ,
                  t.task_id ,
                  t.source_object_type_code,
                  t.source_object_id,
                  ta.assignee_role,
                  ta.last_update_date,
                  ta.creation_date,
                  ta.last_updated_by
             FROM jtf_task_all_assignments ta,
                  jtf_tasks_vl t
            WHERE ta.task_id = t.task_id
              AND ta.task_assignment_id = p_task_assignment_id ;

 -- Cursor to get Note details

    CURSOR get_Note_Dtls (p_jtf_note_id IN NUMBER) IS
           SELECT jtf_note_id ,
                  source_object_code source_object_type_code,
                  source_object_id ,
                  creation_date ,
                  last_update_date,
                  last_updated_by
             FROM jtf_notes_vl
            WHERE jtf_note_id = p_jtf_note_id ;

 -- Cursor to get ecsalation details

    CURSOR get_esc_details (p_task_id IN NUMBER) IS
           SELECT t.task_id ,
                  t.source_objecT_type_code   task_objecT_type_code,
                  t.source_object_id           task_source_object_id ,
                  t.escalation_level,
                  t.creation_date,
                  t.last_update_date,
                  t.last_updated_by,
                  r.reference_code ,
                  r.object_type_code          ref_object_type_code,
                  r.object_id                 ref_object_id ,
                  r.task_reference_id
             FROM jtf_tasks_vl t,
                  jtf_task_references_vl r
            WHERE t.task_id = p_task_id
              AND t.task_id = r.task_id ;

 -- Cursor to get only escalation details on deleting the esc reference

    CURSOR get_del_esc_dtls (p_task_id IN NUMBER) IS
           SELECT t.task_id ,
                  t.source_objecT_type_code   task_objecT_type_code,
                  t.source_object_id           task_source_object_id ,
                  t.escalation_level,
                  t.creation_date,
                  t.last_update_date,
                  t.last_updated_by
             FROM jtf_tasks_vl t
            WHERE t.task_id = p_task_id ;
 --Added by bkanimoz
CURSOR get_inc_details (p_incident_id IN NUMBER) IS
           SELECT incident_number	,
                  incident_type_id,
                  incident_status_id,
                  incident_severity_id,
                  incident_urgency_id,
                  incident_owner_id,
                  owner_group_id,
              customer_id, last_updated_by, summary
	      FROM cs_incidents_all_vl
            WHERE incident_id  =p_incident_id  ;

e_auditing_child_updates EXCEPTION ;

    l_object_version_number     cs_incidents_all_b.object_version_number%TYPE;
    l_notes     		CS_SERVICEREQUEST_PVT.notes_table;
    l_contacts  		CS_SERVICEREQUEST_PVT.contacts_table;
    l_service_request_rec       CS_ServiceRequest_pvt.service_request_rec_type;
    l_sr_update_out_rec         CS_ServiceRequest_pvt.sr_update_out_rec_type;
    l_incident_number		VARCHAR2(64);    -- Bug 7040105
    l_incident_type_id		NUMBER;
    l_incident_status_id	NUMBER;
    l_incident_severity_id	NUMBER;
    l_incident_urgency_id	NUMBER;
    l_incident_owner_id		NUMBER;
    l_owner_group_id		NUMBER;
    l_customer_id		NUMBER;
    l_last_updated_by		NUMBER;
    l_summary			VARCHAR2(240) ;
    l_api_version number;
    l_workflow_process_id NUMBER;

BEGIN

  /** Detect the event raised and determine necessary parameters depending on the event **/

      /**** SR Solution Link Events ****/

      -- SR Solution link updated event

    IF l_event_name  = 'oracle.apps.cs.knowledge.SolutionLink.Updated'  THEN
       l_source_object_code    := p_event.GetValueForParameter('OBJECT_CODE');
       l_source_object_id      := p_event.GetValueForParameter('OBJECT_ID');

       IF ((l_source_object_code = 'SR') AND (l_source_object_id IS NOT NULL ) ) THEN
          l_event_key     := p_event.GetValueForParameter('LINK_ID') ;

          l_updated_entity_code   := 'SR_SOLUTION_LINK';
          l_updated_entity_id     := l_event_key ;
          l_entity_update_date    := p_event.GetValueForParameter('EVENT_DATE');
          l_entity_activity_code  := 'U';
          l_incident_id           := l_source_object_id ;
          l_user_id               :=  p_event.GetValueForParameter('USER_ID');
       END IF ;

      -- SR Solution link Created event

    ELSIF l_event_name  = 'oracle.apps.cs.knowledge.SolutionLinked'  THEN
          l_source_object_code    := p_event.GetValueForParameter('OBJECT_CODE');
          l_source_object_id      := p_event.GetValueForParameter('OBJECT_ID');

          IF ((l_source_object_code = 'SR') AND (l_source_object_id IS NOT NULL ) ) THEN

             l_event_key     := p_event.GetValueForParameter('LINK_ID') ;

             l_updated_entity_id     := l_event_key ;
             l_updated_entity_code   := 'SR_SOLUTION_LINK';
             l_entity_update_date    := p_event.GetValueForParameter('EVENT_DATE');
             l_entity_activity_code  := 'C';
             l_incident_id           := l_source_object_id ;
             l_user_id               :=  p_event.GetValueForParameter('USER_ID');
          END IF ;

      /**** SR Task Events ****/

      -- SR Task Created event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.task.createTask'  THEN

--          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_TYPE_CODE');
--          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');


             l_event_key  := p_event.GetValueForParameter('TASK_ID');

             FOR get_task_dtls_rec IN get_task_dtls(l_event_key)

                 LOOP
                    IF ((get_task_dtls_rec.source_object_type_code = 'SR') AND
                        (get_task_dtls_rec.source_object_id IS NOT NULL ) ) THEN

                       l_updated_entity_id     := l_event_key ;
                       l_updated_entity_code   := 'SR_TASK' ;
                       l_entity_update_date    := get_task_dtls_rec.creation_date;
                       l_entity_activity_code  := 'C';
                       l_incident_id           := get_task_dtls_rec.source_object_id ;
                       l_user_id               := get_task_dtls_rec.last_updated_by ;
                    END IF ;
                 END LOOP;

      -- SR Task Updated event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.task.updateTask'  THEN
--          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_TYPE_CODE');
--          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');


             l_event_key  := p_event.GetValueForParameter('TASK_ID');

             FOR get_task_dtls_rec IN get_task_dtls(l_event_key)

                 LOOP
                    IF ((get_task_dtls_rec.source_object_type_code = 'SR') AND
                        (get_task_dtls_rec.source_object_id IS NOT NULL ) ) THEN

                       l_updated_entity_id     := l_event_key ;
                       l_updated_entity_code   := 'SR_TASK' ;
                       l_entity_update_date    := get_task_dtls_rec.last_update_date ;
                       l_entity_activity_code  := 'U' ;
                       l_incident_id           := get_task_dtls_rec.source_object_id ;
                       l_user_id               := get_task_dtls_rec.last_updated_by ;
                    END IF ;
                 END LOOP ;

      -- SR Task deleted event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.task.deleteTask'  THEN

          l_event_key     := p_event.GetValueForParameter('TASK_ID');

          FOR get_task_dtls_rec IN get_task_dtls(l_event_key)

              LOOP
                 IF ((get_task_dtls_rec.source_object_type_code = 'SR') AND
                     (get_task_dtls_rec.source_object_id IS NOT NULL )) THEN

                    l_updated_entity_id     := l_event_key ;
                    l_updated_entity_code   := 'SR_TASK' ;
                    l_entity_update_date    := get_task_dtls_rec.last_update_date ;
                    l_entity_activity_code  := 'D' ;
                    l_incident_id           := get_task_dtls_rec.source_object_id ;
                    l_user_id               := get_task_dtls_rec.last_updated_by ;

                 END IF ;
              END LOOP ;

      /**** SR Task Assignments Events ****/

      -- SR Task Assignment Created event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.task.createTaskAssignment'  THEN

          l_event_key     := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID') ;

          FOR get_taskAssign_dtls_rec IN get_TaskAssign_dtls (l_event_key)

              LOOP
                 IF ((get_taskAssign_dtls_rec.source_object_type_code = 'SR') AND
                     (get_taskAssign_dtls_rec.source_object_id IS NOT NULL ) AND
                     (get_taskAssign_dtls_rec.assignee_role = 'ASSIGNEE') ) THEN

                     l_updated_entity_id     := get_taskAssign_dtls_rec.task_id ;
                     l_updated_entity_code   := 'SR_TASK' ;
                     l_entity_update_date    := get_taskAssign_dtls_rec.creation_date ;
                     l_entity_activity_code  := 'U';
                     l_incident_id           := get_taskAssign_dtls_rec.source_object_id ;
                     l_user_id               := get_taskAssign_dtls_rec.last_updated_by ;
                 END IF ;
              END LOOP ;

      -- SR Task Assignment Updated event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.task.updateTaskAssignment'  THEN


          l_event_key     := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID') ;

          FOR get_taskAssign_dtls_rec IN get_TaskAssign_dtls (l_event_key)

              LOOP
                 IF ((get_taskAssign_dtls_rec.source_object_type_code = 'SR') AND
                     (get_taskAssign_dtls_rec.source_object_id IS NOT NULL ) AND
                     (get_taskAssign_dtls_rec.assignee_role = 'ASSIGNEE') ) THEN

                     l_updated_entity_id     := get_taskAssign_dtls_rec.task_id ;
                     l_updated_entity_code   := 'SR_TASK' ;
                     l_entity_update_date    := get_taskAssign_dtls_rec.last_update_date ;
                     l_entity_activity_code  := 'U' ;
                     l_incident_id           := get_taskAssign_dtls_rec.source_object_id ;
                     l_user_id               := get_taskAssign_dtls_rec.last_updated_by ;
                 END IF ;
              END LOOP ;

      -- SR Task Assignment Deleted event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.task.deleteTaskAssignment'  THEN

          l_event_key     := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID') ;

          FOR get_taskAssign_dtls_rec IN get_TaskAssign_dtls (l_event_key)

              LOOP
                 IF ((get_taskAssign_dtls_rec.source_object_type_code = 'SR') AND
                     (get_taskAssign_dtls_rec.source_object_id IS NOT NULL ) AND
                     (get_taskAssign_dtls_rec.assignee_role = 'ASSIGNEE') ) THEN

                    l_updated_entity_id     := get_taskAssign_dtls_rec.task_id ;
                    l_updated_entity_code   := 'SR_TASK' ;
                    l_entity_update_date    := get_taskAssign_dtls_rec.last_update_date ;
                    l_entity_activity_code  := 'U' ;
                    l_incident_id           := get_taskAssign_dtls_rec.source_object_id ;
                    l_user_id               := get_taskAssign_dtls_rec.last_updated_by ;
                 END IF ;
              END LOOP ;

      /**** SR Notes Events ****/

      -- SR Note Created event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.notes.create'  THEN

          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_CODE');
          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');

          IF ((l_source_object_code = 'SR') AND
              (l_source_object_id IS NOT NULL ) ) THEN

              l_event_key     := p_event.GetValueForParameter('NOTE_ID') ;

              FOR get_note_dtls_rec IN get_note_dtls (l_event_key)

                 LOOP
                    l_updated_entity_id     := l_event_key ;
                    l_updated_entity_code   := 'SR_NOTE' ;
                    l_entity_update_date    := get_note_dtls_rec.creation_date ;
                    l_entity_activity_code  := 'C' ;
                    l_incident_id           := l_source_object_id ;
                    l_user_id               := get_note_dtls_rec.last_updated_by ;
                 END LOOP ;
          END IF ;

      -- SR Note Updated event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.notes.update'  THEN

          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_CODE');
          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');

          IF ((l_source_object_code = 'SR') AND
             (l_source_object_id IS NOT NULL ) ) THEN

             l_event_key     := p_event.GetValueForParameter('NOTE_ID') ;

             FOR get_note_dtls_rec IN get_note_dtls (l_event_key)

                 LOOP
                    l_updated_entity_id     := l_event_key ;
                    l_updated_entity_code   := 'SR_NOTE' ;
                    l_entity_update_date    := get_note_dtls_rec.last_update_date ;
                    l_entity_activity_code  := 'U' ;
                    l_incident_id           := l_source_object_id ;
                    l_user_id               := get_note_dtls_rec.last_updated_by ;
                 END LOOP ;
          END IF ;

      -- SR Note Deleted event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.notes.delete'  THEN

          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_TYPE_CODE');
          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');

          IF ((l_source_object_code = 'SR') AND
             (l_source_object_id IS NOT NULL ) ) THEN

             l_event_key     := p_event.GetValueForParameter('NOTE_ID') ;

             FOR get_note_dtls_rec IN get_note_dtls (l_event_key)

                 LOOP
                    l_updated_entity_id     := l_event_key ;
                    l_updated_entity_code   := 'SR_NOTE' ;
                    l_entity_update_date    := get_note_dtls_rec.last_update_date ;
                    l_entity_activity_code  := 'D' ;
                    l_incident_id           := l_source_object_id ;
                    l_user_id               := get_note_dtls_rec.last_updated_by ;
                 END LOOP ;
          END IF ;

      /**** SR Task Escalation Events ****/

      -- SR task Escalation Created event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.escalation.createEscalation'  THEN

--          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_TYPE_CODE');
--          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');

             l_event_key  := p_event.GetValueForParameter('TASK_ID');

             FOR get_esc_details_rec IN get_esc_details(l_event_key)

                 LOOP
                    IF ((get_esc_details_rec.ref_object_type_code = 'SR') AND
                        (get_esc_details_rec.ref_object_id IS NOT NULL ) ) THEN

                       l_updated_entity_id     := get_esc_details_rec.task_id ;
                       l_updated_entity_code   := 'SR_ESCALATION' ;
                       l_entity_update_date    := get_esc_details_rec.creation_date;
                       l_entity_activity_code  := 'C';
                       l_incident_id           := get_esc_details_rec.ref_object_id ;
                       l_user_id               := get_esc_details_rec.last_updated_by ;
                    END IF ;
                 END LOOP;

      -- SR task Escalation Updated event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.escalation.updateEscalation'  THEN
--          l_source_object_code    := p_event.GetValueForParameter('SOURCE_OBJECT_TYPE_CODE');
--          l_source_object_id      := p_event.GetValueForParameter('SOURCE_OBJECT_ID');

             l_event_key  := p_event.GetValueForParameter('TASK_ID');

             FOR get_esc_details_rec IN get_esc_details(l_event_key)

                 LOOP
                    IF ((get_esc_details_rec.ref_object_type_code = 'SR') AND
                        (get_esc_details_rec.ref_object_id IS NOT NULL ) ) THEN

                       l_updated_entity_id     := get_esc_details_rec.task_id ;
                       l_updated_entity_code   := 'SR_ESCALATION' ;
                       l_entity_update_date    := get_esc_details_rec.last_update_date ;
                       l_entity_activity_code  := 'U' ;
                       l_incident_id           := get_esc_details_rec.ref_object_id ;
                       l_user_id               := get_esc_details_rec.last_updated_by ;
                    END IF ;
                 END LOOP ;

      -- SR task Escalation Deleted event

    ELSIF l_event_name  = 'oracle.apps.jtf.cac.escalation.deleteEscReference'  THEN

          l_event_key     := p_event.GetValueForParameter('TASK_ID');
          l_source_object_code    := p_event.GetValueForParameter('OBJECT_TYPE_CODE');
          l_source_object_id      := p_event.GetValueForParameter('OBJECT_ID');


--                 IF ((get_esc_details_rec.ref_object_type_code = 'SR') AND
--                     (get_esc_details_rec.ref_object_id IS NOT NULL )) THEN

              IF ((l_source_object_code = 'SR') AND (l_source_object_id IS NOT NULL) ) THEN

                 FOR get_del_esc_dtls_rec IN get_del_esc_dtls(l_event_key)
                     LOOP

--                    l_updated_entity_id     := get_del_esc_dtls_rec.task_id ;
                    l_updated_entity_id     := l_event_key ;
                    l_updated_entity_code   := 'SR_ESCALATION' ;
                    l_entity_update_date    := get_del_esc_dtls_rec.last_update_date ;
                    l_entity_activity_code  := 'D' ;
                    l_incident_id           := l_source_object_id  ;
--                    l_incident_id           := get_del_esc_dtls_rec.ref_object_id ;
                    l_user_id               := get_del_esc_dtls_rec.last_updated_by ;

                     END LOOP ;
              END IF ;

    END IF ;      -- end if detect event


    -- Call SR Child Audit API to create entry in SR audit table.
    IF ((l_updated_entity_code IS NOT NULL) AND (l_incident_id IS NOT NULL) AND
        (l_updated_entity_id IS NOT NULL) ) THEN

--Bug fix 6275359.Commented by bkanimoz on 06-Aug-2007
--Whenever the Notes are updated call the Service Request update API  so that it sends notification and inturn do the auditing


	     CS_SR_AUDIT_CHILD
             (P_incident_id           => l_incident_id,
              P_updated_entity_code   => l_updated_entity_code,
              p_updated_entity_id     => l_updated_entity_id ,
              p_entity_update_date    => l_entity_update_date,
              p_entity_activity_code  => l_entity_activity_code ,
              p_update_program_code   => 'EVENT_SUBSCRIPTION',
              p_user_id               => l_user_id ,
              x_audit_id              => l_audit_id,
              x_return_status         => l_return_status,
	      x_msg_count             => l_msg_count ,
	      x_msg_data              => l_msg_data );

		IF l_return_status <> 'S' THEN
		   RAISE e_auditing_child_updates ;
		END IF;

--Bug fix 6158138.Added by bkanimoz on 06-Aug-2007
--start

CS_ServiceRequest_pvt.initialize_rec(l_service_request_rec);
/*
	select  object_version_number
	into    l_object_version_number
	from    cs_incidents_all_b
	where   incident_id =l_incident_id;


    CS_ServiceRequest_pvt.Update_ServiceRequest(
                 p_api_version           => 4.0,
                 p_init_msg_list         => 'T',
                 p_commit                => 'T',
                 p_validation_level      => fnd_api.g_valid_level_none,
                 x_return_status         => l_return_status,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data,
                 p_request_id            => l_incident_id,
                 p_object_version_number => l_object_version_number,
                 p_resp_appl_id          => NULL,
                 p_resp_id               => NULL,
                 p_last_updated_by       => l_user_id,
                 p_last_update_login     => NULL,
                 p_last_update_date      => sysdate,
                 p_service_request_rec   => l_service_request_rec,
                 p_update_desc_flex      => 'F',
                 p_notes                 => l_notes,
                 p_contacts              => l_contacts,
                 p_audit_comments        => NULL,
                 p_called_by_workflow    => 'F',
                 p_workflow_process_id   => NULL,
                 x_sr_update_out_rec     => l_sr_update_out_rec
             );
*/
 --Added by bkanimoz
--insert into rm_tmp values ('before calling', 'Raise_SR_EVENT' || l_incident_number, rm_tmp_seq.nextval);

--bug 	7389202
If l_event_name  = 'oracle.apps.jtf.cac.notes.create'
or l_event_name  = 'oracle.apps.jtf.cac.notes.update'
or l_event_name  = 'oracle.apps.jtf.cac.notes.delete'
THEN

OPEN get_inc_details(l_incident_id) ;
FETCH get_inc_details INTO l_incident_number		,
			   l_incident_type_id		,
			   l_incident_status_id		,
			   l_incident_severity_id	,
			   l_incident_urgency_id	,
			   l_incident_owner_id		,
			   l_owner_group_id		,
			   l_customer_id		,
			   l_last_updated_by		,
			   l_summary ;
CLOSE get_inc_details;


l_Service_Request_rec.type_id      :=l_incident_type_id		;
l_Service_Request_rec.status_id    :=l_incident_status_id		;
l_Service_Request_rec.severity_id  :=l_incident_severity_id	;
l_Service_Request_rec.urgency_id   :=l_incident_urgency_id	;
l_Service_Request_rec.owner_id         	:=l_incident_owner_id		;
l_Service_Request_rec.owner_group_id   	:=l_owner_group_id		;
l_Service_Request_rec.customer_id      	:=l_customer_id		;
l_Service_Request_rec.summary		:= l_summary ;


CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
p_api_version => l_api_version,
p_init_msg_list => 'T',
p_commit => 'T',
p_validation_level => fnd_api.g_valid_level_none,
p_event_code => 'UPDATE_SERVICE_REQUEST',
p_incident_number => l_incident_number,
p_user_id => l_last_updated_by,
p_resp_id => NULL,
p_resp_appl_id => NULL,
p_old_sr_rec => l_Service_Request_rec,
p_new_sr_rec => l_Service_Request_rec,
p_contacts_table => l_contacts,
p_link_rec => NULL, -- using default value
p_wf_process_id => NULL,
p_owner_id => NULL, -- using default value
p_wf_manual_launch => 'N' , -- using default value
x_wf_process_id => l_workflow_process_id,
x_return_status => l_return_status,
x_msg_count => l_msg_count,
x_msg_data => l_msg_data );

	      IF l_return_status <> 'S' THEN
		   RAISE e_auditing_child_updates ;
		END IF;
--end


      END IF ;
END IF;


RETURN 'SUCCESS';

EXCEPTION
     WHEN e_auditing_child_updates THEN
          WF_CORE.CONTEXT('CS_SR_CHILD_AUDIT_PKG', 'CS_SR_Audit_ChildEntities',
                          l_event_name , p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, 'WARNING');
          return 'WARNING';
     WHEN others THEN
          WF_CORE.CONTEXT('CS_SR_CHILD_AUDIT_PKG', 'CS_SR_Audit_ChildEntities',
                          l_event_name , p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, 'WARNING');
          return 'WARNING';
END CS_SR_Audit_ChildEntities  ;

/*
Modification History
Date     Name       Desc
-------- ---------  ------------------------------------------------------------
03/25/05 smisra     Bug 4028675
                    Modified this procedure and set old unassigned indicator
                    based on old owner and old group if
                    p_owner_status_update_flag is OWNER otherwise set it's
                    value from service request record.
08/15/05 smisra     Set contract_number col using contract_number from SR Rec
                    instead of contract_id column.
10/14/05 smisra     Bug 4674121
                    Added two parameters p_old_inc_responded_by_date and
                    p_old_incident_resolved_date if this procedure is called
                    by update_status procedure then set
                    old_incident_responded_by_date and old_incident_resolved_date
                    of audit record from the parameter values otherwise set these
                    cols from service request record.
11/13/07 gasankar   Bug 6621820
                    Handled the locking issue when trying to update the
		    CS_INCIDENTS_ALL_B
*/
PROCEDURE CS_SR_AUDIT_CHILD
             (P_incident_id           IN NUMBER,
              P_updated_entity_code   IN VARCHAR2 ,
              p_updated_entity_id     IN NUMBER ,
              p_entity_update_date    IN DATE ,
              p_entity_activity_code  IN VARCHAR2 ,
              p_status_id	      IN NUMBER DEFAULT NULL,
              p_old_status_id	      IN NUMBER DEFAULT NULL,
              p_closed_date	      IN DATE DEFAULT NULL,
              p_old_closed_date	      IN DATE DEFAULT NULL,
              p_owner_id	      IN NUMBER DEFAULT NULL,
              p_old_owner_id	      IN NUMBER DEFAULT NULL,
              p_owner_group_id	      IN NUMBER DEFAULT NULL,
              p_old_owner_group_id    IN NUMBER DEFAULT NULL,
              p_resource_type	      IN VARCHAR2 DEFAULT NULL,
              p_old_resource_type     IN VARCHAR2 DEFAULT NULL,
              p_owner_status_upd_flag IN VARCHAR2 DEFAULT 'NONE',
              p_update_program_code   IN VARCHAR2 DEFAULT 'NONE',
              p_user_id               IN NUMBER   DEFAULT NULL,
              p_old_inc_responded_by_date  IN DATE    DEFAULT NULL,
              p_old_incident_resolved_date IN DATE    DEFAULT NULL,
              x_audit_id             OUT NOCOPY NUMBER,
              x_return_status        OUT NOCOPY VARCHAR2,
	      x_msg_count            OUT NOCOPY NUMBER,
	      x_msg_data             OUT NOCOPY VARCHAR2
			   )  IS

l_audit_vals_rec   			  CS_ServiceRequest_PVT.sr_audit_rec_type ;
l_incident_last_modified_date DATE ;
l_service_request_rec         CS_INCIDENTS_ALL_B%ROWTYPE;
--l_return_status 			  VARCHAR2(30) ;

l_status_flag		      VARCHAR2(1);

 SR_Lock_Row                  EXCEPTION; --gasankar

 PRAGMA EXCEPTION_INIT( SR_Lock_Row, -54 ); --gasankar

CURSOR get_sr_date IS
        SELECT *
          FROM cs_incidents_all_b
	 WHERE incident_id = p_incident_id
           FOR UPDATE NOWAIT ;

e_create_audit_failed EXCEPTION ;
 l_text varchar2(240);
 l_num number;

BEGIN

   --Added initilization of return status to Success --anmukher --09/12/03
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Compare SR last Modified date with the entity date and update if entity date is later

	 OPEN get_sr_date ;
	 FETCH get_sr_date INTO l_service_request_rec ;
--	 CLOSE get_sr_date;

	 IF p_entity_update_date > l_service_request_rec.incident_last_modified_date THEN

		UPDATE cs_incidents_all_b
		   SET incident_last_modified_date = NVL(p_entity_update_date,sysdate) ,
                       last_update_date            = sysdate,
                       last_updated_by             = NVL(p_user_id , FND_GLOBAL.user_id)
		 WHERE incident_id = p_incident_id ;


           -- Added by aneemuch on 11/02/2004,
           -- Added code to update cs_incidents_all_tl table. This is due to change in the intermedia index structure
           -- in 11.5.10 where JTF_NOTES will be part of the intermedia index itself. So any change in notes
           -- will require conc prog to sunc intermedia index to be run.

               IF p_updated_entity_code = 'SR_NOTE' THEN
                 UPDATE cs_incidents_all_tl
                    SET text_index = 'A'
                  WHERE incident_id = p_incident_id;
              END IF;

           -- End of code changes by aneemuch 11/02/2004

	 END IF ;


-- Populate Audit Record structure

   -- Initialize Audit record

    CS_ServiceRequest_PVT.Initialize_audit_rec(  p_sr_audit_record   => l_audit_vals_rec) ;


    -- Added for owner update --anmukher --10/16/03
    IF p_owner_status_upd_flag = 'OWNER' THEN

      IF (   (p_owner_id IS NOT NULL AND p_old_owner_id IS NULL)
          OR (p_owner_id IS NULL     AND p_old_owner_id IS NOT NULL)
          OR (p_owner_id IS NOT NULL AND p_old_owner_id IS NOT NULL
             AND p_owner_id <> p_old_owner_id)
         ) THEN

             l_audit_vals_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
             l_audit_vals_rec.INCIDENT_OWNER_ID            := p_owner_id;
             l_audit_vals_rec.OLD_INCIDENT_OWNER_ID        := p_old_owner_id;
      ELSE
             l_audit_vals_rec.CHANGE_INCIDENT_OWNER_FLAG := 'N';
             l_audit_vals_rec.OLD_INCIDENT_OWNER_ID      := l_service_request_rec.incident_owner_id;
             l_audit_vals_rec.INCIDENT_OWNER_ID          := l_service_request_rec.incident_owner_id;
      END IF;

      IF ((p_owner_group_id IS NOT NULL AND p_old_owner_group_id IS NULL)
         OR (p_owner_group_id IS NULL AND p_old_owner_group_id IS NOT NULL)
         OR (p_owner_group_id IS NOT NULL AND p_old_owner_group_id IS NOT NULL
             AND p_owner_group_id <> p_old_owner_group_id)
         ) THEN

             l_audit_vals_rec.change_group_flag := 'Y';
             l_audit_vals_rec.group_id            := p_owner_group_id ;
             l_audit_vals_rec.old_group_id        := p_old_owner_group_id ;
      ELSE
             l_audit_vals_rec.change_group_flag := 'N';
             l_audit_vals_rec.old_group_id      := l_service_request_rec.OWNER_GROUP_ID ;
             l_audit_vals_rec.group_id          := l_service_request_rec.OWNER_GROUP_ID ;
      END IF;

      IF (p_owner_group_id IS NOT NULL AND p_owner_group_id<>FND_API.G_MISS_NUM)
      THEN
             l_audit_vals_rec.group_type:='RS_GROUP';
      ELSE
             l_audit_vals_rec.group_type:=NULL;
      END IF;

      IF ((l_audit_vals_rec.group_type IS NOT NULL
          AND l_audit_vals_rec.old_group_type IS NULL)
          OR (l_audit_vals_rec.group_type IS NULL
          AND l_audit_vals_rec.old_group_type IS NOT NULL))
      THEN
             l_audit_vals_rec.change_group_type_flag   := 'Y';
             l_audit_vals_rec.old_group_type           := l_service_request_rec.group_type ;
      ELSE
             l_audit_vals_rec.change_group_type_flag   := 'N';
             l_audit_vals_rec.old_group_type           := l_service_request_rec.group_type ;
             l_audit_vals_rec.group_type               := l_service_request_rec.group_type ;
      END IF;

      IF ((p_resource_type IS NOT NULL AND p_old_resource_type IS NULL)
         OR (p_resource_type IS NULL AND p_old_resource_type IS NOT NULL)
         OR (p_resource_type IS NOT NULL AND p_old_resource_type IS NOT NULL
             AND p_resource_type <> p_old_resource_type)) THEN

             l_audit_vals_rec.change_resource_type_flag   := 'Y';
             l_audit_vals_rec.resource_type      := p_resource_type ;
             l_audit_vals_rec.old_resource_type  := p_old_resource_type ;
      ELSE
             l_audit_vals_rec.change_resource_type_flag   := 'N';
             l_audit_vals_rec.old_resource_type      := l_service_request_rec.RESOURCE_TYPE ;
             l_audit_vals_rec.resource_type          := l_service_request_rec.RESOURCE_TYPE ;
      END IF;

      l_audit_vals_rec.old_unassigned_indicator := cs_servicerequest_util.get_unassigned_indicator(
                                                  p_old_owner_id, p_old_owner_group_id);

    ELSE

      l_audit_vals_rec.change_incident_owner_flag          := 'N';
      l_audit_vals_rec.incident_owner_id        	   := l_service_request_rec.incident_owner_id;
      l_audit_vals_rec.old_incident_owner_id               := l_service_request_rec.incident_owner_id;

      l_audit_vals_rec.CHANGE_GROUP_FLAG  	   := 'N';
      l_audit_vals_rec.GROUP_ID        		   := l_service_request_rec.OWNER_GROUP_ID;
      l_audit_vals_rec.OLD_GROUP_ID               := l_service_request_rec.OWNER_GROUP_ID;
      l_audit_vals_rec.CHANGE_GROUP_TYPE_FLAG 		:= 'N';
      l_audit_vals_rec.group_type        			:= l_service_request_rec.group_type;
      l_audit_vals_rec.old_group_type        		:= l_service_request_rec.group_type;

      l_audit_vals_rec.CHANGE_RESOURCE_TYPE_FLAG     := 'N';
      l_audit_vals_rec.RESOURCE_TYPE        	   := l_service_request_rec.RESOURCE_TYPE;
      l_audit_vals_rec.OLD_RESOURCE_TYPE        	   := l_service_request_rec.RESOURCE_TYPE;

      l_audit_vals_rec.old_unassigned_indicator   := l_service_request_rec.unassigned_indicator;

    END IF; -- IF p_owner_status_upd_flag = 'OWNER'

    l_audit_vals_rec.CHANGE_ASSIGNED_TIME_FLAG           := 'N';
    l_audit_vals_rec.OWNER_ASSIGNED_TIME                 := l_service_request_rec.OWNER_ASSIGNED_TIME;
    l_audit_vals_rec.old_OWNER_ASSIGNED_TIME             := l_service_request_rec.OWNER_ASSIGNED_TIME;
    l_audit_vals_rec.change_product_revision_flag        := 'N';
    l_audit_vals_rec.product_revision        	         := l_service_request_rec.product_revision;
    l_audit_vals_rec.old_product_revision                := l_service_request_rec.product_revision;
    l_audit_vals_rec.CHANGE_COMP_VER_FLAG 	         := 'N';
    l_audit_vals_rec.component_version        	         := l_service_request_rec.component_version;
    l_audit_vals_rec.old_component_version               := l_service_request_rec.component_version;
    l_audit_vals_rec.CHANGE_SUBCOMP_VER_FLAG 	         := 'N';
    l_audit_vals_rec.subcomponent_version                := l_service_request_rec.subcomponent_version;
    l_audit_vals_rec.old_subcomponent_version            := l_service_request_rec.subcomponent_version;
    l_audit_vals_rec.change_platform_id_flag 	         := 'N';
    l_audit_vals_rec.platform_id        	         := l_service_request_rec.platform_id;
    l_audit_vals_rec.old_platform_id        	         := l_service_request_rec.platform_id;
    l_audit_vals_rec.CHANGE_PLAT_VER_ID_FLAG 	         := 'N';
    l_audit_vals_rec.platform_version_id                 := l_service_request_rec.platform_version_id;
    l_audit_vals_rec.old_platform_version_id             := l_service_request_rec.platform_version_id;
    l_audit_vals_rec.CHANGE_CUSTOMER_PRODUCT_FLAG        := 'N';
    l_audit_vals_rec.customer_product_id                 := l_service_request_rec.customer_product_id;
    l_audit_vals_rec.old_customer_product_id             := l_service_request_rec.customer_product_id;
    l_audit_vals_rec.CHANGE_CP_COMPONENT_ID_FLAG         := 'N';
    l_audit_vals_rec.cp_component_id        	         := l_service_request_rec.cp_component_id;
    l_audit_vals_rec.old_cp_component_id                 := l_service_request_rec.cp_component_id;
    l_audit_vals_rec.CHANGE_CP_COMP_VER_ID_FLAG          := 'N';
    l_audit_vals_rec.cp_component_version_id             := l_service_request_rec.cp_component_version_id;
    l_audit_vals_rec.old_cp_component_version_id          := l_service_request_rec.cp_component_version_id;
    l_audit_vals_rec.change_cp_subcomponent_id_flag       := 'N';
    l_audit_vals_rec.cp_subcomponent_id        		:= l_service_request_rec.cp_subcomponent_id;
    l_audit_vals_rec.old_cp_subcomponent_id      	:= l_service_request_rec.cp_subcomponent_id;
    l_audit_vals_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG        := 'N';
    l_audit_vals_rec.cp_subcomponent_version_id           := l_service_request_rec.cp_subcomponent_version_id;
    l_audit_vals_rec.old_cp_subcomponent_version_id       := l_service_request_rec.cp_subcomponent_version_id;
    l_audit_vals_rec.change_cp_revision_id_flag 	:= 'N';
    l_audit_vals_rec.cp_revision_id        			:= l_service_request_rec.cp_revision_id;
    l_audit_vals_rec.old_cp_revision_id        		:= l_service_request_rec.cp_revision_id;
    l_audit_vals_rec.change_inv_item_revision 		:= 'N';
    l_audit_vals_rec.inv_item_revision        		:= l_service_request_rec.inv_item_revision;
    l_audit_vals_rec.old_inv_item_revision        	:= l_service_request_rec.inv_item_revision;
    l_audit_vals_rec.change_inv_component_id 		:= 'N';
    l_audit_vals_rec.inv_component_id        		:= l_service_request_rec.inv_component_id;
    l_audit_vals_rec.old_inv_component_id        	:= l_service_request_rec.inv_component_id;
    l_audit_vals_rec.change_inv_component_version         := 'N';
    l_audit_vals_rec.inv_component_version                := l_service_request_rec.inv_component_version;
    l_audit_vals_rec.old_inv_component_version            := l_service_request_rec.inv_component_version;
    l_audit_vals_rec.change_inv_subcomponent_id           := 'N';
    l_audit_vals_rec.inv_subcomponent_id        	:= l_service_request_rec.inv_subcomponent_id;
    l_audit_vals_rec.old_inv_subcomponent_id              := l_service_request_rec.inv_subcomponent_id;
    l_audit_vals_rec.CHANGE_INV_SUBCOMP_VERSION 	:= 'N';
    l_audit_vals_rec.inv_subcomponent_version             := l_service_request_rec.inv_subcomponent_version;
    l_audit_vals_rec.old_inv_subcomponent_version         := l_service_request_rec.inv_subcomponent_version;
    l_audit_vals_rec.CHANGE_INVENTORY_ITEM_FLAG 	:= 'N';
    l_audit_vals_rec.inventory_item_id        		:= l_service_request_rec.inventory_item_id;
    l_audit_vals_rec.old_inventory_item_id        	:= l_service_request_rec.inventory_item_id;
    l_audit_vals_rec.CHANGE_PLATFORM_ORG_ID_FLAG 	:= 'N';
    l_audit_vals_rec.inv_platform_org_id        	:= l_service_request_rec.inv_platform_org_id;
    l_audit_vals_rec.old_inv_platform_org_id        := l_service_request_rec.inv_platform_org_id;
    l_audit_vals_rec.CHANGE_RESOLUTION_FLAG 		:= 'N';
    l_audit_vals_rec.EXPECTED_RESOLUTION_DATE       := l_service_request_rec.expected_resolution_date;
    l_audit_vals_rec.OLD_EXPECTED_RESOLUTION_DATE   := l_service_request_rec.expected_resolution_date;
    l_audit_vals_rec.CHANGE_OBLIGATION_FLAG 		:= 'N';
    l_audit_vals_rec.obligation_date        		:= l_service_request_rec.obligation_date;
    l_audit_vals_rec.old_obligation_date        	:= l_service_request_rec.obligation_date;
    l_audit_vals_rec.CHANGE_SITE_FLAG 			:= 'N';
    l_audit_vals_rec.site_id        			:= l_service_request_rec.site_id;
    l_audit_vals_rec.old_site_id        		:= l_service_request_rec.site_id;
    l_audit_vals_rec.CHANGE_TERRITORY_ID_FLAG 		:= 'N';
    l_audit_vals_rec.territory_id        		:= l_service_request_rec.territory_id;
    l_audit_vals_rec.old_territory_id        		:= l_service_request_rec.territory_id;
    l_audit_vals_rec.CHANGE_BILL_TO_FLAG 		:= 'N';
    l_audit_vals_rec.bill_to_contact_id        		:= l_service_request_rec.bill_to_contact_id;
    l_audit_vals_rec.old_bill_to_contact_id        := l_service_request_rec.bill_to_contact_id;
    l_audit_vals_rec.CHANGE_SHIP_TO_FLAG 	   := 'N';
    l_audit_vals_rec.ship_to_contact_id        	   := l_service_request_rec.ship_to_contact_id;
    l_audit_vals_rec.old_ship_to_contact_id        := l_service_request_rec.ship_to_contact_id;

    -- Added for status update --anmukher --10/14/03
    IF p_owner_status_upd_flag = 'STATUS' THEN
      l_audit_vals_rec.change_incident_status_flag := 'Y';
      l_audit_vals_rec.incident_status_id          := p_status_id;
      l_audit_vals_rec.old_incident_status_id      := p_old_status_id;
    ELSE
      l_audit_vals_rec.change_incident_status_flag := 'N';
      l_audit_vals_rec.incident_status_id          := l_service_request_rec.incident_status_id;
      l_audit_vals_rec.old_incident_status_id      := l_service_request_rec.incident_status_id;
    END IF;

    -- Added for status update -- anmukher -- 10/16/03
    IF p_owner_status_upd_flag = 'STATUS' THEN
      l_audit_vals_rec.OLD_INCIDENT_RESOLVED_DATE     := p_old_incident_resolved_date;
      l_audit_vals_rec.OLD_INC_RESPONDED_BY_DATE      := p_old_inc_responded_by_date;
      IF NVL(p_closed_date, TO_DATE('09/09/0099', 'dd/mm/yyyy'))  <>
         NVL(p_old_closed_date, TO_DATE('09/09/0099', 'dd/mm/yyyy')) THEN
        l_audit_vals_rec.CHANGE_CLOSE_DATE_FLAG	   := 'Y';
        l_audit_vals_rec.CLOSE_DATE		   := p_closed_date;
        l_audit_vals_rec.OLD_CLOSE_DATE		   := p_old_closed_date;
      ELSE
        l_audit_vals_rec.CHANGE_CLOSE_DATE_FLAG	   := 'N';
        l_audit_vals_rec.CLOSE_DATE		   := l_service_request_rec.close_date;
        l_audit_vals_rec.OLD_CLOSE_DATE		   := l_service_request_rec.close_date;
      END IF;
    ELSE
      l_audit_vals_rec.CHANGE_CLOSE_DATE_FLAG	   := 'N';
      l_audit_vals_rec.CLOSE_DATE		   := l_service_request_rec.close_date;
      l_audit_vals_rec.OLD_CLOSE_DATE		   := l_service_request_rec.close_date;
      l_audit_vals_rec.OLD_INCIDENT_RESOLVED_DATE     := l_service_request_rec.INCIDENT_RESOLVED_DATE;
      l_audit_vals_rec.OLD_INC_RESPONDED_BY_DATE      := l_service_request_rec.INC_RESPONDED_BY_DATE;
    END IF;

    l_audit_vals_rec.CHANGE_INCIDENT_TYPE_FLAG 	   := 'N';
    l_audit_vals_rec.INCIDENT_TYPE_ID        	   := l_service_request_rec.incident_type_id;
    l_audit_vals_rec.OLD_INCIDENT_TYPE_ID          := l_service_request_rec.incident_type_id;
    l_audit_vals_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'N';
    l_audit_vals_rec.INCIDENT_SEVERITY_ID          := l_service_request_rec.incident_severity_id ;
    l_audit_vals_rec.OLD_INCIDENT_SEVERITY_ID      := l_service_request_rec.incident_severity_id ;
    l_audit_vals_rec.CHANGE_INCIDENT_DATE_FLAG     := 'N';
    l_audit_vals_rec.INCIDENT_DATE        	   := l_service_request_rec.incident_date;
    l_audit_vals_rec.OLD_INCIDENT_DATE        	   := l_service_request_rec.incident_date;
    l_audit_vals_rec.CHANGE_PLAT_VER_ID_FLAG  	   := 'N';
    l_audit_vals_rec.PLATFORM_VERSION_ID           := l_service_request_rec.PLATFORM_VERSION_ID;
    l_audit_vals_rec.OLD_PLATFORM_VERSION_ID       := l_service_request_rec.PLATFORM_VERSION_ID;
    l_audit_vals_rec.CHANGE_LANGUAGE_ID_FLAG  	   := 'N';
    l_audit_vals_rec.LANGUAGE_ID        	   := l_service_request_rec.LANGUAGE_ID;
    l_audit_vals_rec.OLD_LANGUAGE_ID        	   := l_service_request_rec.LANGUAGE_ID;
    l_audit_vals_rec.CHANGE_INV_ORGANIZATION_FLAG  := 'N';
    l_audit_vals_rec.INV_ORGANIZATION_ID           := l_service_request_rec.inv_organization_id;
    l_audit_vals_rec.OLD_INV_ORGANIZATION_ID       := l_service_request_rec.inv_organization_id;

    -- Added for auditing of status update -- anmukher -- 10/16/03
    IF p_owner_status_upd_flag = 'STATUS' THEN
      l_status_flag := get_status_flag(p_status_id);
      IF NVL(l_status_flag, '@') <> NVL(l_service_request_rec.STATUS_FLAG, '@') THEN
        l_audit_vals_rec.CHANGE_STATUS_FLAG  	   := 'Y';
        l_audit_vals_rec.STATUS_FLAG        	   := l_status_flag;
      ELSE
        l_audit_vals_rec.CHANGE_STATUS_FLAG  	   := 'N';
        l_audit_vals_rec.STATUS_FLAG        	   := l_service_request_rec.STATUS_FLAG;
      END IF;
    ELSE
      l_audit_vals_rec.CHANGE_STATUS_FLAG  	   := 'N';
      l_audit_vals_rec.STATUS_FLAG        	   := l_service_request_rec.STATUS_FLAG;
    END IF;

    IF p_update_program_code <> 'NONE' THEN
        l_audit_vals_rec.LAST_UPDATE_PROGRAM_CODE     := p_update_program_code;
        l_audit_vals_rec.OLD_LAST_UPDATE_PROGRAM_CODE := l_service_request_rec.LAST_UPDATE_PROGRAM_CODE;
    ELSE
        l_audit_vals_rec.LAST_UPDATE_PROGRAM_CODE     := l_service_request_rec.LAST_UPDATE_PROGRAM_CODE;
        l_audit_vals_rec.OLD_LAST_UPDATE_PROGRAM_CODE := l_service_request_rec.LAST_UPDATE_PROGRAM_CODE;
    END IF ;


    l_audit_vals_rec.OLD_STATUS_FLAG        	   := l_service_request_rec.STATUS_FLAG;
    l_audit_vals_rec.CHANGE_PRIMARY_CONTACT_FLAG   := 'N';
    l_audit_vals_rec.PRIMARY_CONTACT_ID        	   := l_service_request_rec.PRIMARY_CONTACT_ID;
    l_audit_vals_rec.OLD_PRIMARY_CONTACT_ID        := l_service_request_rec.PRIMARY_CONTACT_ID;
    l_audit_vals_rec.CUSTOMER_ID                := l_service_request_rec.CUSTOMER_ID;
    l_audit_vals_rec.OLD_CUSTOMER_ID                := l_service_request_rec.CUSTOMER_ID;
    l_audit_vals_rec.BILL_TO_SITE_USE_ID        := l_service_request_rec.BILL_TO_SITE_USE_ID;
    l_audit_vals_rec.OLD_BILL_TO_SITE_USE_ID        := l_service_request_rec.BILL_TO_SITE_USE_ID;
    l_audit_vals_rec.EMPLOYEE_ID                := l_service_request_rec.EMPLOYEE_ID;
    l_audit_vals_rec.OLD_EMPLOYEE_ID                := l_service_request_rec.EMPLOYEE_ID;
    l_audit_vals_rec.SHIP_TO_SITE_USE_ID        := l_service_request_rec.SHIP_TO_SITE_USE_ID;
    l_audit_vals_rec.OLD_SHIP_TO_SITE_USE_ID        := l_service_request_rec.SHIP_TO_SITE_USE_ID;
    l_audit_vals_rec.PROBLEM_CODE               := l_service_request_rec.PROBLEM_CODE;
    l_audit_vals_rec.OLD_PROBLEM_CODE               := l_service_request_rec.PROBLEM_CODE;
    l_audit_vals_rec.ACTUAL_RESOLUTION_DATE     := l_service_request_rec.ACTUAL_RESOLUTION_DATE;
    l_audit_vals_rec.OLD_ACTUAL_RESOLUTION_DATE     := l_service_request_rec.ACTUAL_RESOLUTION_DATE;
    l_audit_vals_rec.INSTALL_SITE_USE_ID        := l_service_request_rec.INSTALL_SITE_USE_ID;
    l_audit_vals_rec.OLD_INSTALL_SITE_USE_ID        := l_service_request_rec.INSTALL_SITE_USE_ID;
    l_audit_vals_rec.CURRENT_SERIAL_NUMBER      := l_service_request_rec.CURRENT_SERIAL_NUMBER;
    l_audit_vals_rec.OLD_CURRENT_SERIAL_NUMBER      := l_service_request_rec.CURRENT_SERIAL_NUMBER;
    l_audit_vals_rec.SYSTEM_ID                  := l_service_request_rec.SYSTEM_ID;
    l_audit_vals_rec.OLD_SYSTEM_ID                  := l_service_request_rec.SYSTEM_ID;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_2       := l_service_request_rec.INCIDENT_ATTRIBUTE_2;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_3       := l_service_request_rec.INCIDENT_ATTRIBUTE_3;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_4       := l_service_request_rec.INCIDENT_ATTRIBUTE_4;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_5       := l_service_request_rec.INCIDENT_ATTRIBUTE_5;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_6       := l_service_request_rec.INCIDENT_ATTRIBUTE_6;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_7       := l_service_request_rec.INCIDENT_ATTRIBUTE_7;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_7       := l_service_request_rec.INCIDENT_ATTRIBUTE_7;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_8       := l_service_request_rec.INCIDENT_ATTRIBUTE_8;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_9       := l_service_request_rec.INCIDENT_ATTRIBUTE_9;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_10      := l_service_request_rec.INCIDENT_ATTRIBUTE_10;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_11      := l_service_request_rec.INCIDENT_ATTRIBUTE_11;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_12      := l_service_request_rec.INCIDENT_ATTRIBUTE_12;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_13      := l_service_request_rec.INCIDENT_ATTRIBUTE_13;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_14      := l_service_request_rec.INCIDENT_ATTRIBUTE_14;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_ATTRIBUTE_15            := l_service_request_rec.INCIDENT_ATTRIBUTE_15;
    l_audit_vals_rec.OLD_INCIDENT_ATTRIBUTE_1       := l_service_request_rec.INCIDENT_ATTRIBUTE_1;
    l_audit_vals_rec.INCIDENT_CONTEXT                 := l_service_request_rec.INCIDENT_CONTEXT;
    l_audit_vals_rec.OLD_INCIDENT_CONTEXT           := l_service_request_rec.INCIDENT_CONTEXT;
    l_audit_vals_rec.RESOLUTION_CODE                  := l_service_request_rec.RESOLUTION_CODE;
    l_audit_vals_rec.OLD_RESOLUTION_CODE            := l_service_request_rec.RESOLUTION_CODE;
    l_audit_vals_rec.ORIGINAL_ORDER_NUMBER            := l_service_request_rec.ORIGINAL_ORDER_NUMBER;
    l_audit_vals_rec.OLD_ORIGINAL_ORDER_NUMBER      := l_service_request_rec.ORIGINAL_ORDER_NUMBER;
    l_audit_vals_rec.PURCHASE_ORDER_NUMBER            := l_service_request_rec.PURCHASE_ORDER_NUM;
    l_audit_vals_rec.OLD_PURCHASE_ORDER_NUMBER      := l_service_request_rec.PURCHASE_ORDER_NUM;
    l_audit_vals_rec.PUBLISH_FLAG                     := l_service_request_rec.PUBLISH_FLAG;
    l_audit_vals_rec.OLD_PUBLISH_FLAG               := l_service_request_rec.PUBLISH_FLAG;
    l_audit_vals_rec.QA_COLLECTION_ID                 := l_service_request_rec.QA_COLLECTION_ID;
    l_audit_vals_rec.OLD_QA_COLLECTION_ID           := l_service_request_rec.QA_COLLECTION_ID;
    l_audit_vals_rec.CONTRACT_ID                      := l_service_request_rec.CONTRACT_ID;
    l_audit_vals_rec.OLD_CONTRACT_ID                := l_service_request_rec.CONTRACT_ID;
    l_audit_vals_rec.CONTRACT_SERVICE_ID              := l_service_request_rec.CONTRACT_SERVICE_ID;
    l_audit_vals_rec.OLD_CONTRACT_SERVICE_ID        := l_service_request_rec.CONTRACT_SERVICE_ID;
    l_audit_vals_rec.TIME_ZONE_ID                     := l_service_request_rec.TIME_ZONE_ID;
    l_audit_vals_rec.OLD_TIME_ZONE_ID               := l_service_request_rec.TIME_ZONE_ID;
    l_audit_vals_rec.ACCOUNT_ID                       := l_service_request_rec.ACCOUNT_ID;
    l_audit_vals_rec.OLD_ACCOUNT_ID                 := l_service_request_rec.ACCOUNT_ID;
    l_audit_vals_rec.TIME_DIFFERENCE                  := l_service_request_rec.TIME_DIFFERENCE;
    l_audit_vals_rec.OLD_TIME_DIFFERENCE            := l_service_request_rec.TIME_DIFFERENCE;
    l_audit_vals_rec.CUSTOMER_PO_NUMBER               := l_service_request_rec.CUSTOMER_PO_NUMBER;
    l_audit_vals_rec.OLD_CUSTOMER_PO_NUMBER         := l_service_request_rec.CUSTOMER_PO_NUMBER;
    l_audit_vals_rec.CUSTOMER_TICKET_NUMBER           := l_service_request_rec.CUSTOMER_TICKET_NUMBER;
    l_audit_vals_rec.OLD_CUSTOMER_TICKET_NUMBER     := l_service_request_rec.CUSTOMER_TICKET_NUMBER;
    l_audit_vals_rec.CUSTOMER_SITE_ID                 := l_service_request_rec.CUSTOMER_SITE_ID;
    l_audit_vals_rec.OLD_CUSTOMER_SITE_ID           := l_service_request_rec.CUSTOMER_SITE_ID;
    l_audit_vals_rec.CALLER_TYPE                      := l_service_request_rec.CALLER_TYPE;
    l_audit_vals_rec.OLD_CALLER_TYPE                := l_service_request_rec.CALLER_TYPE;
    l_audit_vals_rec.PROJECT_NUMBER                   := l_service_request_rec.PROJECT_NUMBER;
    l_audit_vals_rec.OLD_PROJECT_NUMBER             := l_service_request_rec.PROJECT_NUMBER;
    l_audit_vals_rec.PLATFORM_VERSION                 := l_service_request_rec.PLATFORM_VERSION;
    l_audit_vals_rec.OLD_PLATFORM_VERSION           := l_service_request_rec.PLATFORM_VERSION;
    l_audit_vals_rec.DB_VERSION                       := l_service_request_rec.DB_VERSION;
    l_audit_vals_rec.OLD_DB_VERSION                 := l_service_request_rec.DB_VERSION;
    l_audit_vals_rec.CUST_PREF_LANG_ID                := l_service_request_rec.CUST_PREF_LANG_ID;
    l_audit_vals_rec.OLD_CUST_PREF_LANG_ID          := l_service_request_rec.CUST_PREF_LANG_ID;
    l_audit_vals_rec.TIER                             := l_service_request_rec.TIER;
    l_audit_vals_rec.OLD_TIER                       := l_service_request_rec.TIER;
    l_audit_vals_rec.CATEGORY_ID                      := l_service_request_rec.CATEGORY_ID;
    l_audit_vals_rec.OLD_CATEGORY_ID                := l_service_request_rec.CATEGORY_ID;
    l_audit_vals_rec.OPERATING_SYSTEM                 := l_service_request_rec.OPERATING_SYSTEM;
    l_audit_vals_rec.OLD_OPERATING_SYSTEM           := l_service_request_rec.OPERATING_SYSTEM;
    l_audit_vals_rec.DATABASE                         := l_service_request_rec.DATABASE;
    l_audit_vals_rec.OLD_DATABASE                   := l_service_request_rec.DATABASE;
    l_audit_vals_rec.GROUP_TERRITORY_ID               := l_service_request_rec.GROUP_TERRITORY_ID;
    l_audit_vals_rec.OLD_GROUP_TERRITORY_ID         := l_service_request_rec.GROUP_TERRITORY_ID;
    l_audit_vals_rec.COMM_PREF_CODE                   := l_service_request_rec.COMM_PREF_CODE;
    l_audit_vals_rec.OLD_COMM_PREF_CODE             := l_service_request_rec.COMM_PREF_CODE;
    l_audit_vals_rec.LAST_UPDATE_CHANNEL              := l_service_request_rec.LAST_UPDATE_CHANNEL;
    l_audit_vals_rec.OLD_LAST_UPDATE_CHANNEL        := l_service_request_rec.LAST_UPDATE_CHANNEL;
    l_audit_vals_rec.CUST_PREF_LANG_CODE              := l_service_request_rec.CUST_PREF_LANG_CODE;
    l_audit_vals_rec.OLD_CUST_PREF_LANG_CODE        := l_service_request_rec.CUST_PREF_LANG_CODE;
    l_audit_vals_rec.ERROR_CODE                       := l_service_request_rec.ERROR_CODE;
    l_audit_vals_rec.OLD_ERROR_CODE                 := l_service_request_rec.ERROR_CODE;
    l_audit_vals_rec.CATEGORY_SET_ID                  := l_service_request_rec.CATEGORY_SET_ID;
    l_audit_vals_rec.OLD_CATEGORY_SET_ID            := l_service_request_rec.CATEGORY_SET_ID;
    l_audit_vals_rec.EXTERNAL_REFERENCE               := l_service_request_rec.EXTERNAL_REFERENCE;
    l_audit_vals_rec.OLD_EXTERNAL_REFERENCE         := l_service_request_rec.EXTERNAL_REFERENCE;
    l_audit_vals_rec.INCIDENT_OCCURRED_DATE           := l_service_request_rec.INCIDENT_OCCURRED_DATE;
    l_audit_vals_rec.OLD_INCIDENT_OCCURRED_DATE     := l_service_request_rec.INCIDENT_OCCURRED_DATE;
    l_audit_vals_rec.INCIDENT_RESOLVED_DATE           := l_service_request_rec.INCIDENT_RESOLVED_DATE;
    l_audit_vals_rec.INC_RESPONDED_BY_DATE            := l_service_request_rec.INC_RESPONDED_BY_DATE;
    l_audit_vals_rec.INCIDENT_LOCATION_ID             := l_service_request_rec.INCIDENT_LOCATION_ID;
    l_audit_vals_rec.OLD_INCIDENT_LOCATION_ID       := l_service_request_rec.INCIDENT_LOCATION_ID;
    l_audit_vals_rec.INCIDENT_ADDRESS                 := l_service_request_rec.INCIDENT_ADDRESS;
    l_audit_vals_rec.OLD_INCIDENT_ADDRESS           := l_service_request_rec.INCIDENT_ADDRESS;
    l_audit_vals_rec.INCIDENT_CITY                    := l_service_request_rec.INCIDENT_CITY;
    l_audit_vals_rec.OLD_INCIDENT_CITY              := l_service_request_rec.INCIDENT_CITY;
    l_audit_vals_rec.INCIDENT_STATE                   := l_service_request_rec.INCIDENT_STATE;
    l_audit_vals_rec.OLD_INCIDENT_STATE             := l_service_request_rec.INCIDENT_STATE;
    l_audit_vals_rec.INCIDENT_COUNTRY                 := l_service_request_rec.INCIDENT_COUNTRY;
    l_audit_vals_rec.OLD_INCIDENT_COUNTRY           := l_service_request_rec.INCIDENT_COUNTRY;
    l_audit_vals_rec.INCIDENT_PROVINCE                := l_service_request_rec.INCIDENT_PROVINCE;
    l_audit_vals_rec.OLD_INCIDENT_PROVINCE          := l_service_request_rec.INCIDENT_PROVINCE;
    l_audit_vals_rec.INCIDENT_POSTAL_CODE             := l_service_request_rec.INCIDENT_POSTAL_CODE;
    l_audit_vals_rec.OLD_INCIDENT_POSTAL_CODE       := l_service_request_rec.INCIDENT_POSTAL_CODE;
    l_audit_vals_rec.INCIDENT_COUNTY                  := l_service_request_rec.INCIDENT_COUNTY;
    l_audit_vals_rec.OLD_INCIDENT_COUNTY            := l_service_request_rec.INCIDENT_COUNTY;
    l_audit_vals_rec.SR_CREATION_CHANNEL              := l_service_request_rec.SR_CREATION_CHANNEL;
    l_audit_vals_rec.OLD_SR_CREATION_CHANNEL        := l_service_request_rec.SR_CREATION_CHANNEL;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_1             := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_2             := l_service_request_rec.EXTERNAL_ATTRIBUTE_2;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_3             := l_service_request_rec.EXTERNAL_ATTRIBUTE_3;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_4             := l_service_request_rec.EXTERNAL_ATTRIBUTE_4;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_5             := l_service_request_rec.EXTERNAL_ATTRIBUTE_5;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_6             := l_service_request_rec.EXTERNAL_ATTRIBUTE_6;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_7             := l_service_request_rec.EXTERNAL_ATTRIBUTE_7;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_8             := l_service_request_rec.EXTERNAL_ATTRIBUTE_8;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_9             := l_service_request_rec.EXTERNAL_ATTRIBUTE_9;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_10            := l_service_request_rec.EXTERNAL_ATTRIBUTE_10;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_11            := l_service_request_rec.EXTERNAL_ATTRIBUTE_11;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_12            := l_service_request_rec.EXTERNAL_ATTRIBUTE_12;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_13            := l_service_request_rec.EXTERNAL_ATTRIBUTE_13;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_14            := l_service_request_rec.EXTERNAL_ATTRIBUTE_14;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_ATTRIBUTE_15            := l_service_request_rec.EXTERNAL_ATTRIBUTE_15;
    l_audit_vals_rec.OLD_EXTERNAL_ATTRIBUTE_1       := l_service_request_rec.EXTERNAL_ATTRIBUTE_1;
    l_audit_vals_rec.EXTERNAL_CONTEXT                 := l_service_request_rec.EXTERNAL_CONTEXT;
    l_audit_vals_rec.OLD_EXTERNAL_CONTEXT           := l_service_request_rec.EXTERNAL_CONTEXT;
    l_audit_vals_rec.CREATION_PROGRAM_CODE            := l_service_request_rec.CREATION_PROGRAM_CODE;
    l_audit_vals_rec.OLD_CREATION_PROGRAM_CODE        := l_service_request_rec.CREATION_PROGRAM_CODE;
    l_audit_vals_rec.COVERAGE_TYPE                    := l_service_request_rec.COVERAGE_TYPE;
    l_audit_vals_rec.OLD_COVERAGE_TYPE              := l_service_request_rec.COVERAGE_TYPE;
    l_audit_vals_rec.BILL_TO_ACCOUNT_ID               := l_service_request_rec.BILL_TO_ACCOUNT_ID;
    l_audit_vals_rec.OLD_BILL_TO_ACCOUNT_ID         := l_service_request_rec.BILL_TO_ACCOUNT_ID;
    l_audit_vals_rec.SHIP_TO_ACCOUNT_ID               := l_service_request_rec.SHIP_TO_ACCOUNT_ID;
    l_audit_vals_rec.OLD_SHIP_TO_ACCOUNT_ID         := l_service_request_rec.SHIP_TO_ACCOUNT_ID;
    l_audit_vals_rec.CUSTOMER_EMAIL_ID                := l_service_request_rec.CUSTOMER_EMAIL_ID;
    l_audit_vals_rec.OLD_CUSTOMER_EMAIL_ID          := l_service_request_rec.CUSTOMER_EMAIL_ID;
    l_audit_vals_rec.CUSTOMER_PHONE_ID                := l_service_request_rec.CUSTOMER_PHONE_ID;
    l_audit_vals_rec.OLD_CUSTOMER_PHONE_ID          := l_service_request_rec.CUSTOMER_PHONE_ID;
    l_audit_vals_rec.BILL_TO_PARTY_ID                 := l_service_request_rec.BILL_TO_PARTY_ID;
    l_audit_vals_rec.OLD_BILL_TO_PARTY_ID           := l_service_request_rec.BILL_TO_PARTY_ID;
    l_audit_vals_rec.SHIP_TO_PARTY_ID                 := l_service_request_rec.SHIP_TO_PARTY_ID;
    l_audit_vals_rec.OLD_SHIP_TO_PARTY_ID           := l_service_request_rec.SHIP_TO_PARTY_ID;
    l_audit_vals_rec.BILL_TO_SITE_ID                  := l_service_request_rec.BILL_TO_SITE_ID;
    l_audit_vals_rec.OLD_BILL_TO_SITE_ID            := l_service_request_rec.BILL_TO_SITE_ID;
    l_audit_vals_rec.SHIP_TO_SITE_ID                  := l_service_request_rec.SHIP_TO_SITE_ID;
    l_audit_vals_rec.OLD_SHIP_TO_SITE_ID            := l_service_request_rec.SHIP_TO_SITE_ID;
    l_audit_vals_rec.PROGRAM_LOGIN_ID                 := l_service_request_rec.PROGRAM_LOGIN_ID;
    l_audit_vals_rec.OLD_PROGRAM_LOGIN_ID           := l_service_request_rec.PROGRAM_LOGIN_ID;
    l_audit_vals_rec.INCIDENT_POINT_OF_INTEREST       := l_service_request_rec.INCIDENT_POINT_OF_INTEREST;
    l_audit_vals_rec.OLD_INCIDENT_POINT_OF_INTEREST := l_service_request_rec.INCIDENT_POINT_OF_INTEREST;
    l_audit_vals_rec.INCIDENT_CROSS_STREET            := l_service_request_rec.INCIDENT_CROSS_STREET;
    l_audit_vals_rec.OLD_INCIDENT_CROSS_STREET      := l_service_request_rec.INCIDENT_CROSS_STREET;
    l_audit_vals_rec.INCIDENT_DIRECTION_QUALIF        := l_service_request_rec.incident_direction_qualifier;
    l_audit_vals_rec.OLD_INCIDENT_DIRECTION_QUALIF  := l_service_request_rec.incident_direction_qualifier;
    l_audit_vals_rec.INCIDENT_DISTANCE_QUALIF         := l_service_request_rec.incident_distance_qualifier;
    l_audit_vals_rec.OLD_INCIDENT_DISTANCE_QUALIF   := l_service_request_rec.incident_distance_qualifier;
    l_audit_vals_rec.INCIDENT_DISTANCE_QUAL_UOM       := l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM;
    l_audit_vals_rec.OLD_INCIDENT_DISTANCE_QUAL_UOM := l_service_request_rec.INCIDENT_DISTANCE_QUAL_UOM;
    l_audit_vals_rec.INCIDENT_ADDRESS2                := l_service_request_rec.INCIDENT_ADDRESS2;
    l_audit_vals_rec.OLD_INCIDENT_ADDRESS2          := l_service_request_rec.INCIDENT_ADDRESS2;
    l_audit_vals_rec.INCIDENT_ADDRESS3                := l_service_request_rec.INCIDENT_ADDRESS3;
    l_audit_vals_rec.OLD_INCIDENT_ADDRESS3          := l_service_request_rec.INCIDENT_ADDRESS3;
    l_audit_vals_rec.INCIDENT_ADDRESS4                := l_service_request_rec.INCIDENT_ADDRESS4;
    l_audit_vals_rec.OLD_INCIDENT_ADDRESS4          := l_service_request_rec.INCIDENT_ADDRESS4;
    l_audit_vals_rec.INCIDENT_ADDRESS_STYLE           := l_service_request_rec.INCIDENT_ADDRESS_STYLE;
    l_audit_vals_rec.OLD_INCIDENT_ADDRESS_STYLE     := l_service_request_rec.INCIDENT_ADDRESS_STYLE;
    l_audit_vals_rec.INCIDENT_ADDR_LNS_PHONETIC       := l_service_request_rec.incident_addr_lines_phonetic;
    l_audit_vals_rec.OLD_INCIDENT_ADDR_LNS_PHONETIC := l_service_request_rec.incident_addr_lines_phonetic;
    l_audit_vals_rec.INCIDENT_PO_BOX_NUMBER           := l_service_request_rec.INCIDENT_PO_BOX_NUMBER;
    l_audit_vals_rec.OLD_INCIDENT_PO_BOX_NUMBER     := l_service_request_rec.INCIDENT_PO_BOX_NUMBER;
    l_audit_vals_rec.INCIDENT_HOUSE_NUMBER            := l_service_request_rec.INCIDENT_HOUSE_NUMBER;
    l_audit_vals_rec.OLD_INCIDENT_HOUSE_NUMBER      := l_service_request_rec.INCIDENT_HOUSE_NUMBER;
    l_audit_vals_rec.INCIDENT_STREET_SUFFIX          := l_service_request_rec.INCIDENT_STREET_SUFFIX;
    l_audit_vals_rec.OLD_INCIDENT_STREET_SUFFIX    := l_service_request_rec.INCIDENT_STREET_SUFFIX;
    l_audit_vals_rec.INCIDENT_STREET                  := l_service_request_rec.INCIDENT_STREET;
    l_audit_vals_rec.OLD_INCIDENT_STREET            := l_service_request_rec.INCIDENT_STREET;
    l_audit_vals_rec.INCIDENT_STREET_NUMBER           := l_service_request_rec.INCIDENT_STREET_NUMBER;
    l_audit_vals_rec.OLD_INCIDENT_STREET_NUMBER     := l_service_request_rec.INCIDENT_STREET_NUMBER;
    l_audit_vals_rec.INCIDENT_FLOOR                   := l_service_request_rec.INCIDENT_FLOOR;
    l_audit_vals_rec.OLD_INCIDENT_FLOOR             := l_service_request_rec.INCIDENT_FLOOR;
    l_audit_vals_rec.INCIDENT_SUITE                   := l_service_request_rec.INCIDENT_SUITE;
    l_audit_vals_rec.OLD_INCIDENT_SUITE             := l_service_request_rec.INCIDENT_SUITE;
    l_audit_vals_rec.INCIDENT_POSTAL_PLUS4_CODE       := l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE;
    l_audit_vals_rec.OLD_INCIDENT_POSTAL_PLUS4_CODE := l_service_request_rec.INCIDENT_POSTAL_PLUS4_CODE;
    l_audit_vals_rec.INCIDENT_POSITION                := l_service_request_rec.INCIDENT_POSITION;
    l_audit_vals_rec.OLD_INCIDENT_POSITION          := l_service_request_rec.INCIDENT_POSITION;
    l_audit_vals_rec.INCIDENT_LOC_DIRECTIONS          := l_service_request_rec.incident_location_directions;
    l_audit_vals_rec.OLD_INCIDENT_LOC_DIRECTIONS    := l_service_request_rec.incident_location_directions;
    l_audit_vals_rec.INCIDENT_LOC_DESCRIPTION         := l_service_request_rec.incident_location_description;
    l_audit_vals_rec.OLD_INCIDENT_LOC_DESCRIPTION   := l_service_request_rec.incident_location_description;
    l_audit_vals_rec.INSTALL_SITE_ID                  := l_service_request_rec.INSTALL_SITE_ID;
    l_audit_vals_rec.OLD_INSTALL_SITE_ID                  := l_service_request_rec.INSTALL_SITE_ID;
    l_audit_vals_rec.TIER_VERSION                     := l_service_request_rec.TIER_VERSION;
    l_audit_vals_rec.OLD_TIER_VERSION                     := l_service_request_rec.TIER_VERSION;
    l_audit_vals_rec.ORG_ID                           := l_service_request_rec.ORIGINAL_ORDER_NUMBER;
    l_audit_vals_rec.OLD_ORG_ID                           := l_service_request_rec.ORIGINAL_ORDER_NUMBER;
    l_audit_vals_rec.CONTRACT_NUMBER                  := l_service_request_rec.CONTRACT_NUMBER;
    l_audit_vals_rec.OLD_CONTRACT_NUMBER                  := l_service_request_rec.CONTRACT_NUMBER;
    l_audit_vals_rec.DEF_DEFECT_ID                    := l_service_request_rec.DEF_DEFECT_ID;
    l_audit_vals_rec.OLD_DEF_DEFECT_ID                    := l_service_request_rec.DEF_DEFECT_ID;
    l_audit_vals_rec.DEF_DEFECT_ID2                   := l_service_request_rec.DEF_DEFECT_ID2;
    l_audit_vals_rec.OLD_DEF_DEFECT_ID2                   := l_service_request_rec.DEF_DEFECT_ID2;
    l_audit_vals_rec.UPDATED_ENTITY_CODE              := P_updated_entity_code ;
    l_audit_vals_rec.UPDATED_ENTITY_ID                := p_updated_entity_id ;
    l_audit_vals_rec.INCIDENT_LAST_MODIFIED_DATE      := p_entity_update_date;
    l_audit_vals_rec.ENTITY_ACTIVITY_CODE             := p_entity_activity_code;
    --anmukher --09/12/03
    l_audit_vals_rec.OLD_INC_OBJECT_VERSION_NUMBER    := l_service_request_rec.OBJECT_VERSION_NUMBER;
    --Removed addition of 1 to object version number since SR Header record is not updated
    --anmukher -- 10/15/03
    l_audit_vals_rec.INC_OBJECT_VERSION_NUMBER        := l_service_request_rec.OBJECT_VERSION_NUMBER;
    l_audit_vals_rec.OLD_INC_REQUEST_ID               := l_service_request_rec.REQUEST_ID;
    l_audit_vals_rec.INC_REQUEST_ID                   := l_service_request_rec.REQUEST_ID;
    l_audit_vals_rec.OLD_INC_PROGRAM_APPLICATION_ID   := l_service_request_rec.PROGRAM_APPLICATION_ID;
    l_audit_vals_rec.INC_PROGRAM_APPLICATION_ID       := l_service_request_rec.PROGRAM_APPLICATION_ID;
    l_audit_vals_rec.OLD_INC_PROGRAM_ID               := l_service_request_rec.PROGRAM_ID;
    l_audit_vals_rec.INC_PROGRAM_ID                   := l_service_request_rec.PROGRAM_ID;
    l_audit_vals_rec.OLD_INC_PROGRAM_UPDATE_DATE      := l_service_request_rec.PROGRAM_UPDATE_DATE;
    l_audit_vals_rec.INC_PROGRAM_UPDATE_DATE          := l_service_request_rec.PROGRAM_UPDATE_DATE;
    l_audit_vals_rec.OLD_OWNING_DEPARTMENT_ID         := l_service_request_rec.OWNING_DEPARTMENT_ID;
    l_audit_vals_rec.OWNING_DEPARTMENT_ID             := l_service_request_rec.OWNING_DEPARTMENT_ID;
    l_audit_vals_rec.OLD_INCIDENT_LOCATION_TYPE       := l_service_request_rec.INCIDENT_LOCATION_TYPE;
    l_audit_vals_rec.INCIDENT_LOCATION_TYPE           := l_service_request_rec.INCIDENT_LOCATION_TYPE;
    l_audit_vals_rec.UNASSIGNED_INDICATOR             := l_service_request_rec.UNASSIGNED_INDICATOR;
    l_audit_vals_rec.OLD_ORG_ID                       := l_service_request_rec.ORG_ID ;
    l_audit_vals_rec.ORG_ID                           := l_service_request_rec.ORG_ID ;
    l_audit_vals_rec.INCIDENT_NUMBER                  := l_service_request_rec.INCIDENT_NUMBER ;
    l_audit_vals_rec.OLD_INCIDENT_NUMBER              := l_service_request_rec.INCIDENT_NUMBER ;
-- audit component R12 project
    l_audit_vals_rec.OLD_MAINT_ORGANIZATION_ID          := l_service_request_rec.MAINT_ORGANIZATION_ID ;
    l_audit_vals_rec.MAINT_ORGANIZATION_ID              := l_service_request_rec.MAINT_ORGANIZATION_ID ;

-- Call CS_ServiceRequest_PVT.Create_Audit_Record API to create SR Audit record.

  CS_ServiceRequest_PVT.Create_Audit_Record (
          p_api_version         => 2.0,
          p_init_msg_list       => FND_API.G_FALSE ,
          p_commit              => FND_API.G_FALSE ,
          p_request_id          => p_incident_id ,
          p_audit_id            => null ,
          p_audit_vals_rec      => l_audit_vals_rec ,
          p_user_id             => NVL(p_user_id,FND_GLOBAL.USER_ID),
          p_last_update_date    => sysdate,
          p_creation_date       => sysdate,
          x_return_status       => x_return_status ,
          x_msg_count           => x_msg_count ,
          x_msg_data            => x_msg_data ,
          x_audit_id            => x_audit_id );

	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE e_create_audit_failed ;
	 END IF ;

	 CLOSE get_sr_date;

EXCEPTION
     WHEN e_create_audit_failed THEN
          CLOSE get_sr_date;
          x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN SR_Lock_Row THEN
       IF (get_sr_date%ISOPEN) THEN
         CLOSE get_sr_date;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );

     WHEN others THEN
          CLOSE get_sr_date;
          l_text  := sqlerrm ;
          l_num   := sqlcode ;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CS_SR_AUDIT_CHILD;

-- Added for status update --anmukher -- 10/16/03
FUNCTION GET_STATUS_FLAG( p_incident_status_id IN  NUMBER)
   RETURN VARCHAR2 IS
     CURSOR get_close_flag IS
     SELECT close_flag
     FROM   cs_incident_statuses_b
     WHERE  incident_status_id = p_incident_status_id;

     l_closed_flag VARCHAR2(1);
     l_status_flag VARCHAR2(1):='O';
   BEGIN
     OPEN get_close_flag;
     FETCH get_close_flag INTO l_closed_flag;
     CLOSE get_close_flag;

     IF l_closed_flag = 'Y' THEN
        l_status_flag:= 'C';
     ELSE
        l_status_flag:= 'O';
     END IF;
     RETURN(l_status_flag);

END GET_STATUS_FLAG;

END CS_SR_CHILD_AUDIT_PKG;

/
