--------------------------------------------------------
--  DDL for Package Body JTF_TASK_WF_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_WF_EVENTS_PVT" AS
/* $Header: jtftkbeb.pls 115.8 2004/02/27 10:53:09 sachoudh noship $ */
  PROCEDURE publish_create_task (
       P_TASK_REC		IN	jtf_tasks_pvt.Task_Rec_type,
       x_return_status  OUT NOCOPY       VARCHAR2
  )
  IS
   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.cac.task.createTask';
   l_task_record            jtf_tasks_pvt.Task_Rec_type := p_task_rec;

  BEGIN
    --Get the item key
	l_list := NULL;
    l_key := get_item_key(l_event_name);
	Compare_and_set_attr_to_list('TASK_ID', NULL, l_task_record.task_id, 'C', l_list,'N');
	Compare_and_set_attr_to_list('SOURCE_OBJECT_TYPE_CODE', NULL, l_task_record.source_object_type_code, 'C',l_list, 'N');
    Compare_and_set_attr_to_list('SOURCE_OBJECT_ID', NULL, l_task_record.source_object_id, 'C',l_list, 'N');
	Compare_and_set_attr_to_list('ENABLE_WORKFLOW', NULL, l_task_record.enable_workflow, 'C', l_list,'N');
	Compare_and_set_attr_to_list('ABORT_WORKFLOW', NULL, l_task_record.abort_workflow, 'C',l_list, 'N');

    -- Raise the create task event
    wf_event.raise3(
			       p_event_name        => l_event_name,
			       p_event_key         => l_key,
			       p_parameter_list    => l_list,
			       p_send_date         => sysdate
				  );

	x_return_status  :=
         wf_event.getvalueforparameter (
            'X_RETURN_STATUS',
            l_list
     );

    l_list.DELETE;


  END publish_create_task;

  PROCEDURE publish_update_task
  (
       P_TASK_REC_OLD		IN	jtf_tasks_pvt.Task_Rec_type,
       P_TASK_REC_NEW		IN	jtf_tasks_pvt.Task_Rec_type,
       x_return_status  OUT NOCOPY       VARCHAR2
  ) IS
   l_list                       WF_PARAMETER_LIST_T;
   l_key                        varchar2(240);
   l_event_name                 varchar2(240);
   l_task_record_old            jtf_tasks_pvt.Task_Rec_type := p_task_rec_old;
   l_task_record_new            jtf_tasks_pvt.Task_Rec_type := p_task_rec_new;

 BEGIN
	l_list := NULL;
    l_event_name := 'oracle.apps.jtf.cac.task.updateTask';
    l_key := get_item_key(l_event_name);

	Compare_and_set_attr_to_list('TASK_ID',NULL,l_task_record_new.task_id, 'U', l_list,'N');
	Compare_and_set_attr_to_list('TASK_AUDIT_ID',NULL,l_task_record_new.task_audit_id, 'U', l_list, 'N');
    Compare_and_set_attr_to_list('SOURCE_OBJECT_TYPE_CODE',l_task_record_old.source_object_type_code,l_task_record_new.source_object_type_code, 'U', l_list, 'Y');
    Compare_and_set_attr_to_list('SOURCE_OBJECT_ID',l_task_record_old.source_object_id,l_task_record_new.source_object_id, 'U', l_list, 'Y');
    Compare_and_set_attr_to_list('ENABLE_WORKFLOW', NULL, l_task_record_new.enable_workflow, 'U', l_list,'N');
	Compare_and_set_attr_to_list('ABORT_WORKFLOW', NULL, l_task_record_new.abort_workflow, 'U',l_list, 'N');


	-- Raise the update task Event
    wf_event.raise3(
			       p_event_name        => l_event_name,
			       p_event_key         => l_key,
			       p_parameter_list    => l_list,
			       p_send_date         => sysdate
				  );

	x_return_status  :=
         wf_event.getvalueforparameter (
            'X_RETURN_STATUS',
            l_list
         );
    l_list.DELETE;


 END publish_update_task;

  PROCEDURE publish_delete_task (
       P_TASK_REC		IN	jtf_tasks_pvt.Task_Rec_type,
       x_return_status  OUT NOCOPY       VARCHAR2
  )
  IS
   l_list		WF_PARAMETER_LIST_T;
   l_key		varchar2(240);
   l_event_name		varchar2(240) := 'oracle.apps.jtf.cac.task.deleteTask';
  BEGIN
    l_list := NULL;
    --Get the item key
    l_key := get_item_key(l_event_name);
	Compare_and_set_attr_to_list('TASK_ID', p_task_rec.task_id, NULL, 'D', l_list,'N');
	Compare_and_set_attr_to_list('SOURCE_OBJECT_TYPE_CODE', p_task_rec.source_object_type_code, NULL, 'D', l_list,'N');
    Compare_and_set_attr_to_list('SOURCE_OBJECT_ID', p_task_rec.source_object_id, NULL, 'D', l_list,'N');
	Compare_and_set_attr_to_list('ENABLE_WORKFLOW',p_task_rec.enable_workflow, NULL, 'D', l_list,'N');
	Compare_and_set_attr_to_list('ABORT_WORKFLOW',p_task_rec.abort_workflow, NULL, 'D',l_list, 'N');

    -- Raise delete task Event
   wf_event.raise3(
			       p_event_name        => l_event_name,
			       p_event_key         => l_key,
			       p_parameter_list    => l_list,
			       p_send_date         => sysdate
				  );

	x_return_status  :=
         wf_event.getvalueforparameter (
            'X_RETURN_STATUS',
            l_list
         );
    l_list.DELETE;


 END publish_delete_task;

 PROCEDURE publish_create_assignment (
      P_ASSIGNMENT_REC	IN	jtf_task_assignments_pvt.task_assignments_rec,
      x_return_status  OUT NOCOPY       VARCHAR2
  )
  IS
    l_list          WF_PARAMETER_LIST_T;
    l_key     VARCHAR2(240);
	l_event_name    VARCHAR2(240) := 'oracle.apps.jtf.cac.task.createTaskAssignment';

  BEGIN
    l_list := NULL;
    l_key := get_item_key(l_event_name);

	Compare_and_set_attr_to_list('TASK_ASSIGNMENT_ID', NULL, P_ASSIGNMENT_REC.task_assignment_id,'C',l_list,'N');
	Compare_and_set_attr_to_list('TASK_ID', NULL, P_ASSIGNMENT_REC.task_id,'C',l_list,'N');
    Compare_and_set_attr_to_list('RESOURCE_TYPE_CODE', NULL, P_ASSIGNMENT_REC.resource_type_code,'C',l_list);
    Compare_and_set_attr_to_list('RESOURCE_ID', NULL, P_ASSIGNMENT_REC.resource_id,'C',l_list);
	Compare_and_set_attr_to_list('ASSIGNMENT_STATUS_ID',NULL ,P_ASSIGNMENT_REC.assignment_status_id,'C',l_list);
	Compare_and_set_attr_to_list('ACTUAL_START_DATE',NULL ,P_ASSIGNMENT_REC.actual_start_date,'C',l_list);
	Compare_and_set_attr_to_list('ACTUAL_END_DATE',NULL ,P_ASSIGNMENT_REC.actual_end_date ,'C',l_list);
	Compare_and_set_attr_to_list('ASSIGNEE_ROLE',NULL ,P_ASSIGNMENT_REC.assignee_role ,'C',l_list);
	Compare_and_set_attr_to_list('SHOW_ON_CALENDAR',NULL ,P_ASSIGNMENT_REC.show_on_calendar ,'C',l_list);
	Compare_and_set_attr_to_list('CATEGORY_ID',NULL ,P_ASSIGNMENT_REC.category_id ,'C',l_list);
	Compare_and_set_attr_to_list('ENABLE_WORKFLOW', NULL, P_ASSIGNMENT_REC.enable_workflow, 'C', l_list,'N');
	Compare_and_set_attr_to_list('ABORT_WORKFLOW', NULL, P_ASSIGNMENT_REC.abort_workflow, 'C',l_list, 'N');

	wf_event.raise3(
			       p_event_name        => l_event_name,
			       p_event_key         => l_key,
			       p_parameter_list    => l_list,
			       p_send_date         => sysdate
				  );

	x_return_status  :=
         wf_event.getvalueforparameter (
            'X_RETURN_STATUS',
            l_list
         );

	l_list.DELETE;


  END;

  PROCEDURE publish_update_assignment (
      P_ASSIGNMENT_REC_NEW	IN	jtf_task_assignments_pvt.task_assignments_rec,
	  P_ASSIGNMENT_REC_OLD	IN	jtf_task_assignments_pvt.task_assignments_rec,
      x_return_status  OUT NOCOPY       VARCHAR2
  )
  IS
    l_list   WF_PARAMETER_LIST_T;
    l_key    VARCHAR2(240);
	l_event_name   VARCHAR2(240) := 'oracle.apps.jtf.cac.task.updateTaskAssignment';
  BEGIN
    l_key := get_item_key(l_event_name);

	Compare_and_set_attr_to_list('TASK_ASSIGNMENT_ID', P_ASSIGNMENT_REC_OLD.task_assignment_id, P_ASSIGNMENT_REC_NEW.task_assignment_id, 'U', l_list,'N');
    Compare_and_set_attr_to_list('TASK_ID', P_ASSIGNMENT_REC_OLD.task_id, P_ASSIGNMENT_REC_NEW.task_id, 'U', l_list,'N');
	Compare_and_set_attr_to_list('RESOURCE_TYPE_CODE', P_ASSIGNMENT_REC_OLD.resource_type_code,P_ASSIGNMENT_REC_NEW.resource_type_code,'U',l_list,'Y');
    Compare_and_set_attr_to_list('RESOURCE_ID',P_ASSIGNMENT_REC_OLD.resource_id,P_ASSIGNMENT_REC_NEW.resource_id,'U',l_list,'Y');
	Compare_and_set_attr_to_list('ASSIGNMENT_STATUS_ID',P_ASSIGNMENT_REC_OLD.assignment_status_id,P_ASSIGNMENT_REC_NEW.assignment_status_id,'U',l_list,'Y');
	Compare_and_set_attr_to_list('ACTUAL_START_DATE',P_ASSIGNMENT_REC_OLD.actual_start_date,P_ASSIGNMENT_REC_NEW.actual_start_date,'U',l_list,'Y');
	Compare_and_set_attr_to_list('ACTUAL_END_DATE',P_ASSIGNMENT_REC_OLD.actual_end_date, P_ASSIGNMENT_REC_NEW.actual_end_date ,'U',l_list,'Y');
	Compare_and_set_attr_to_list('ASSIGNEE_ROLE',P_ASSIGNMENT_REC_OLD.assignee_role,P_ASSIGNMENT_REC_NEW.assignee_role ,'U',l_list,'Y');
	Compare_and_set_attr_to_list('SHOW_ON_CALENDAR',P_ASSIGNMENT_REC_OLD.show_on_calendar, P_ASSIGNMENT_REC_NEW.show_on_calendar ,'U',l_list,'Y');
	Compare_and_set_attr_to_list('CATEGORY_ID',P_ASSIGNMENT_REC_OLD.category_id, P_ASSIGNMENT_REC_NEW.category_id ,'U',l_list,'Y');
    Compare_and_set_attr_to_list('ENABLE_WORKFLOW', NULL, P_ASSIGNMENT_REC_OLD.enable_workflow, 'U', l_list,'N');
	Compare_and_set_attr_to_list('ABORT_WORKFLOW', NULL, P_ASSIGNMENT_REC_OLD.abort_workflow, 'U',l_list, 'N');

	wf_event.raise3(
			       p_event_name        => l_event_name,
			       p_event_key         => l_key,
			       p_parameter_list    => l_list,
			       p_send_date         => sysdate
				  );

	x_return_status  :=
         wf_event.getvalueforparameter (
            'X_RETURN_STATUS',
            l_list
         );
	l_list.DELETE;

  END;

  PROCEDURE publish_delete_assignment (
      P_ASSIGNMENT_REC	IN	jtf_task_assignments_pvt.task_assignments_rec,
      x_return_status  OUT NOCOPY       VARCHAR2
  )
  IS
   l_list		    WF_PARAMETER_LIST_T;
   l_key		varchar2(240);
   l_event_name		varchar2(240) := 'oracle.apps.jtf.cac.task.deleteTaskAssignment';
 BEGIN
    l_key := get_item_key(l_event_name);
	Compare_and_set_attr_to_list('TASK_ASSIGNMENT_ID', P_ASSIGNMENT_REC.task_assignment_id, NULL,'D',l_list,'N');
    Compare_and_set_attr_to_list('TASK_ID', P_ASSIGNMENT_REC.task_id, NULL,'D',l_list,'N');
	Compare_and_set_attr_to_list('ASSIGNEE_ROLE', P_ASSIGNMENT_REC.assignee_role, NULL,'D',l_list,'N');
	Compare_and_set_attr_to_list('RESOURCE_TYPE_CODE',P_ASSIGNMENT_REC.resource_type_code, NULL, 'D',l_list,'N');
    Compare_and_set_attr_to_list('RESOURCE_ID', P_ASSIGNMENT_REC.resource_id,  NULL,'D',l_list,'N');
	Compare_and_set_attr_to_list('ASSIGNMENT_STATUS_ID',P_ASSIGNMENT_REC.assignment_status_id, NULL, 'D',l_list,'N');
    Compare_and_set_attr_to_list('ENABLE_WORKFLOW', P_ASSIGNMENT_REC.enable_workflow, NULL,  'D', l_list,'N');
	Compare_and_set_attr_to_list('ABORT_WORKFLOW', P_ASSIGNMENT_REC.abort_workflow, NULL, 'D',l_list, 'N');

    wf_event.raise3(
			       p_event_name        => l_event_name,
			       p_event_key         => l_key,
			       p_parameter_list    => l_list,
			       p_send_date         => sysdate
				  );

	x_return_status  :=
         wf_event.getvalueforparameter (
            'X_RETURN_STATUS',
            l_list
         );
    l_list.DELETE;

 END;

  FUNCTION get_item_key(p_event_name IN VARCHAR2)
  RETURN VARCHAR2
  IS
  l_key varchar2(240);
  BEGIN
  	SELECT p_event_name ||'-'|| jtf_task_wf_events_s.nextval INTO l_key FROM DUAL;
	RETURN l_key;
  END get_item_key;

  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN VARCHAR2,
    P_NEW_VALUE IN VARCHAR2,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
	PUBLISH_IF_CHANGE  IN VARCHAR2 DEFAULT 'Y'
  )
  IS
  BEGIN
     IF    (P_ACTION = 'C')
	 THEN
		    IF (P_NEW_VALUE IS NOT NULL)
			THEN
	          wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
			END IF;
     ELSIF (P_ACTION = 'U')
	 THEN
		    IF (PUBLISH_IF_CHANGE = 'N')
			THEN
			    wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
			ELSE IF (PUBLISH_IF_CHANGE = 'Y') AND ((P_NEW_VALUE IS NULL) OR (P_OLD_VALUE IS NULL) OR  (P_NEW_VALUE <> P_OLD_VALUE)
                                                                         OR (P_ATTRIBUTE_NAME = 'RESOURCE_TYPE_CODE'))
			     THEN
			           wf_event.addparametertolist ('NEW_'||P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
					   wf_event.addparametertolist ('OLD_'||P_ATTRIBUTE_NAME, P_OLD_VALUE, P_LIST);
                 ELSE IF (PUBLISH_IF_CHANGE = 'Y') AND (P_NEW_VALUE IS NOT NULL) AND (P_OLD_VALUE IS NOT NULL)
				          AND (P_NEW_VALUE = P_OLD_VALUE)
					   THEN
					   	  wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
				      END IF;
			     END IF;
			END IF;
     ELSIF (P_ACTION = 'D')
	 THEN
		    IF (P_OLD_VALUE IS NOT NULL)
			THEN
	           wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_OLD_VALUE, P_LIST);
		    END IF;
	 END IF;
  END;
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN NUMBER,
    P_NEW_VALUE IN NUMBER,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
	PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  )
  IS
  BEGIN
     compare_and_set_attr_to_list(P_ATTRIBUTE_NAME,to_char(P_OLD_VALUE),to_char(P_NEW_VALUE),
	                              P_ACTION,P_LIST,PUBLISH_IF_CHANGE);
  END;
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN DATE,
    P_NEW_VALUE IN DATE,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
	PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  )
  IS
  BEGIN
     compare_and_set_attr_to_list(P_ATTRIBUTE_NAME,to_char(P_OLD_VALUE,'YYYY-MM-DD HH24:MI:SS'),to_char(P_NEW_VALUE,'YYYY-MM-DD HH24:MI:SS'),
	                              P_ACTION,P_LIST,PUBLISH_IF_CHANGE);
  END;

END;

/
